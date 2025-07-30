import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'as foundation;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import 'package:news_app/models/category_model.dart'as models;
import '../services/news_service.dart';
import '../services/local_cache_service.dart';

class NewsRepository {
  final NewsAPIService _apiService;
  final SharedPreferences _prefs;
  final LocalCacheService cacheService;
  final Dio _dio;
   String _bookmarksKey = 'bookmarked_articles';

  // Cache durations
  static const Duration _headlineCacheDuration = Duration(minutes: 30);
  static const Duration _searchCacheDuration = Duration(minutes: 60);
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Timer for search debouncing
  Timer? _searchDebounceTimer;

  NewsRepository({
    required NewsAPIService apiService,
    required SharedPreferences prefs,
    required this.cacheService,
    required Dio dio,
  })  : _apiService = apiService,
        _prefs = prefs,
        _dio = dio;

  // 1. Get Top Headlines with Cache Fallback
  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'headlines_$country';
    
    try {
      // Return cached data if available and not forcing refresh
      if (!forceRefresh) {
        final cached = await _getCachedArticles(cacheKey); // Added await
        if (cached != null) return cached;
      }

      // Fetch from API
      final response = await _apiService.getTopHeadlines(country: country);
      final articles = (response['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();

      // Cache the results
      await _cacheArticles(cacheKey, articles, _headlineCacheDuration);
      return articles;
    } catch (e) {
      foundation.debugPrint('API Error: $e');
      // Fallback to cache if available
      final cached = await _getCachedArticles(cacheKey); 
      if (cached != null) return cached;
      rethrow;
    }
  }
  Future<List<Article>> getCachedHeadlinesOnly() async {
    return await cacheService.getCachedArticles();
  }

  Future<void> refreshTopHeadlinesInBackground() async {
    try {
      final response = await _apiService.getTopHeadlines();
      final List<Article> articles = (response['articles'] as List)
       .map((item) => Article.fromJson(item as Map<String, dynamic>))
    .toList();
      await cacheService.cacheArticles(articles);
    } catch (_) {
      
    }
  }

  Future<List<Article>> getNewsByCategory({
  required models.Category category,
  int page = 1,
  int pageSize = 20,
  bool forceRefresh = false,
}) async {
  final cacheKey = 'category_${category.id}_${page}_${pageSize}'; 

  try {
    
    if (!forceRefresh) {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    
    final response = await _apiService.getNewsByCategory(
      category: category.name,
      page: page,
      pageSize: pageSize,
    );

    
    final articles = (response['articles'] as List?) 
        ?.map((json) => Article.fromJson(json))
        .toList() ?? []; 

  
    if (articles.isNotEmpty) {
      await _cacheArticles(cacheKey, articles, _headlineCacheDuration);
    }

    return articles;
  } catch (e, stackTrace) {
    foundation.debugPrint('Category Error: $e\n$stackTrace'); 
    
    final cached = await _getCachedArticles(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    
    
    throw Exception('Failed to load category news: ${category.name}. $e');
  }
}
  
 CancelToken? _searchCancelToken;

Future<List<Article>> searchArticles({
  required String query,
  bool cancelPrevious = true,
}) async {
  final cacheKey = 'search_$query';

  
  if (cancelPrevious && _searchCancelToken != null && !_searchCancelToken!.isCancelled) {
    _searchCancelToken!.cancel("Cancelled previous search");
  }

  _searchCancelToken = CancelToken();

  final completer = Completer<List<Article>>();

  _searchDebounceTimer?.cancel(); 
  _searchDebounceTimer = Timer(_debounceDuration, () async {
    try {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) {
        completer.complete(cached);
        return;
      }

      final response = await _apiService.searchNews(query: query, cancelToken: _searchCancelToken);
      final articles = (response['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();

      await _cacheArticles(cacheKey, articles, _searchCacheDuration);
      completer.complete(articles);
    } catch (e) {
      completer.completeError(e);
    }
  });

  return completer.future;
}

  
  Future<void> bookmarkArticle(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    final updated = bookmarks.where((a) => a.url != article.url).toList()
      ..add(article.copyWith(isBookmarked: true));

    await _prefs.setString(
      'bookmarked_articles',
      jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
  }

  
  Future<List<Article>> getBookmarkedArticles() async {
    final jsonString = _prefs.getString('bookmarked_articles');
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      foundation.debugPrint('Error loading bookmarks: $e');
      return [];
    }
  }

 
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((key) => 
      key.startsWith('headlines_') || 
      key.startsWith('category_') || 
      key.startsWith('search_'));
    
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  
  Future<void> _cacheArticles(
    String key,
    List<Article> articles,
    Duration duration,
  ) async {
    await _prefs.setString(
      key,
      jsonEncode({
        'articles': articles.map((a) => a.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiresIn': duration.inMilliseconds,
      }),
    );
  }

  
  Future<List<Article>?> _getCachedArticles(String key) async {
    final cached = _prefs.getString(key);
    if (cached == null) return null;

    try {
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = decoded['timestamp'] as int;
      final expiresIn = decoded['expiresIn'] as int;

      if (DateTime.now().millisecondsSinceEpoch - timestamp > expiresIn) {
        await _prefs.remove(key); 
        return null;
      }

      return (decoded['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();
    } catch (e) {
      foundation.debugPrint('Cache parse error: $e');
      await _prefs.remove(key); 
      return null;
    }
  }

  
  Future<bool> hasCachedData() async {
    return _prefs.getKeys().any((key) => 
      key.startsWith('headlines_') || 
      key.startsWith('category_'));
  }
  Future<void> toggleBookmark(Article article) async {
  final bookmarks = await getBookmarkedArticles();
  final exists = bookmarks.any((a) => a.url == article.url);

  if (exists) {
    
    bookmarks.removeWhere((a) => a.url == article.url);
  } else {
    
    bookmarks.add(article);
  }

  await _saveBookmarkedArticles(bookmarks);
}
Future<void> _saveBookmarkedArticles(List<Article> articles) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedList = articles.map((a) => jsonEncode(a.toJson())).toList();
  await prefs.setStringList(_bookmarksKey, encodedList);
}
}