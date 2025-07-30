import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/models/category_model.dart';
import '../models/article_model.dart';
import '../repositories/news_repositories.dart';
import 'news_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;
  List<Article> _bookmarkedArticles = [];
  List<Article> _articles = [];
  List<Article> get bookmarks => _bookmarkedArticles;
  
  int _currentPage = 1;
  bool _hasMore = true;
  Category? _currentCategory;
  String? _searchQuery;
  bool _isFetching = false;

  NewsCubit(this._repository) : super(NewsInitial()){
  _loadBookmarks();
}

  
  Future<void> fetchTopHeadlines({bool forceRefresh = false}) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _searchQuery = null;
      _currentCategory = null;
      _articles.clear();

      final result = await _repository.getTopHeadlines(
        forceRefresh: forceRefresh,
      );

      if (result.isEmpty) {
        emit(NewsEmpty("there is no news now"));
      } else {
        _articles = result;
        _hasMore = result.length >= 20;
        emit(NewsLoaded(_articles, bookmarkedArticles: _bookmarkedArticles, hasMore: _hasMore));

      }
    } catch (_) {
      final cached = await _repository.getCachedHeadlinesOnly();
      if (cached.isNotEmpty) {
        emit(NewsOffline(cached));
      } else {
        emit(NewsError('something went wrong will loading the news', canRetry: true));
      }
    }
  }
  Future<void> _loadBookmarks() async {
  _bookmarkedArticles = await _repository.getBookmarkedArticles();
}

  
  Future<void> fetchByCategory(Category category) async {
    
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _currentCategory = category;
      _searchQuery = null;
      _articles.clear();

      final result = await _repository.getNewsByCategory(category : category);
      if (result.isEmpty) {
        emit(NewsEmpty("there is no news in this category"));
      } else {
        _articles = result;
        _hasMore = result.length >= 20;
        emit(NewsLoaded(_articles, hasMore: _hasMore));
      }
    } catch (_) {
      emit(NewsError('faild to load', canRetry: true));
    }
  }

  
  Future<void> searchArticles(String query) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _searchQuery = query;
      _currentCategory = null;
      _articles.clear();

      final result = await _repository.searchArticles(query : query);
      if (result.isEmpty) {
        emit(NewsEmpty("no result in search"));
      } else {
        _articles = result;
        _hasMore = result.length >= 20;
        emit(NewsLoaded(_articles, hasMore: _hasMore));
      }
    } catch (_) {
      emit(NewsError('faild in search', canRetry: true));
    }
  }

  
  Future<void> refreshNews() async {
    if (_searchQuery != null) {
      await searchArticles(_searchQuery!);
    } else if (_currentCategory != null) {
      await fetchByCategory(_currentCategory!);
    } else {
      await fetchTopHeadlines(forceRefresh: true);
    }
  }

  
  Future<void> loadMoreArticles() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    try {
      _currentPage++;

      List<Article> newArticles = [];

      if (_searchQuery != null) {
        newArticles = await _repository.searchArticles(query:_searchQuery!);
      } else if (_currentCategory != null) {
        newArticles = await _repository.getNewsByCategory(category:_currentCategory!, page: _currentPage);
      } else {
        newArticles = await _repository.getTopHeadlines();
      }

      _articles.addAll(newArticles);
      _hasMore = newArticles.length >= 20;
      emit(NewsLoaded(_articles, hasMore: _hasMore));
    } catch (_) {
      emit(NewsError('faild to load more', canRetry: true));
    } finally {
      _isFetching = false;
    }
  }

  
  Future<void> toggleBookmark(Article article) async {
    await _repository.toggleBookmark(article);
    
  }

  Future<void> getBookmarkedArticles() async {
    emit(NewsLoading());
    final _bookmarkedArticles = await _repository.getBookmarkedArticles();
    if (bookmarks.isEmpty) {
      emit(NewsEmpty("there is no article"));
    } else {
     emit(NewsLoaded(_bookmarkedArticles, bookmarkedArticles: _bookmarkedArticles, hasMore: false));
    }
  }
  Future<void> saveBookmarks(String userId, List<Article> articles) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('bookmarks_$userId', jsonEncode(articles.map((a) => a.toJson()).toList()));
}
Future<bool> isBookmarked(String articleId) async {
  final bookmarks = await _repository.getBookmarkedArticles();
  return bookmarks.any((article) => article.id == articleId);
}


  
}
