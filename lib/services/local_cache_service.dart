import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';

class LocalCacheService {
  static const _cacheKey = 'cached_articles';
  static const _timestampKey = 'cache_timestamp';
  static const _maxCacheSize = 100; // أعلى عدد من المقالات
  static const _cacheExpiryMinutes = 30;

  /// Cache articles with timestamp
  Future<void> cacheArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final limitedArticles = articles.take(_maxCacheSize).toList();
    final jsonList = limitedArticles.map((e) => e.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Load articles from cache if not expired
  Future<List<Article>> getCachedArticles() async {
    final prefs = await SharedPreferences.getInstance();

    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp != null) {
      final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      if (diff.inMinutes > _cacheExpiryMinutes) {
        await clearCache(); // حذف الكاش المنتهي
        return [];
      }
    }

    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    final List decoded = json.decode(jsonString);
    return decoded.map((e) => Article.fromJson(e)).toList();
  }

  /// Check if cache is expired
  Future<bool> isCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return true;
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    return diff.inMinutes > _cacheExpiryMinutes;
  }

  /// Clear only expired cache
  Future<void> clearExpiredCache() async {
    if (await isCacheExpired()) {
      await clearCache();
    }
  }

  /// Force clear all cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
  Future<void> saveBookmarks(String userId, List<Article> articles) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('bookmarks_$userId', jsonEncode(articles.map((a) => a.toJson()).toList()));
}

}
