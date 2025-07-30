import 'package:equatable/equatable.dart';
import '../models/article_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final List<Article> bookmarkedArticles;
  final bool hasMore;

  const NewsLoaded(this.articles,{this.bookmarkedArticles = const [], this.hasMore = false});
  bool isBookmarked(String articleId) {
    return bookmarkedArticles.any((article) => article.id == articleId);
  }

  @override
  List<Object?> get props => [articles,bookmarkedArticles, hasMore];
}

class NewsError extends NewsState {
  final String message;
  final bool canRetry;

  const NewsError(this.message, {this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

class NewsEmpty extends NewsState {
  final String message;

  const NewsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class NewsOffline extends NewsState {
  final List<Article> cachedArticles;

  const NewsOffline(this.cachedArticles);

  @override
  List<Object?> get props => [cachedArticles];
}
