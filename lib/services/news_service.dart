import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsAPIService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '965ef4927041449bab169ba0a380160d';
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _cacheDuration = Duration(minutes: 15);

  late final Dio _dio;
  final SharedPreferences _prefs;
  

  NewsAPIService({Dio? dio, SharedPreferences? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance() as SharedPreferences {
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {'X-Api-Key': _apiKey},
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      _CacheInterceptor(_prefs),
      RetryInterceptor(dio: _dio),
      _ErrorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  // 1. Get Top Headlines
  Future<Map<String, dynamic>> getTopHeadlines({
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    final cacheKey = 'headlines_$country-$page-$pageSize';
    
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'country': country,
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          extra: {'cacheKey': cacheKey, 'cacheDuration': _cacheDuration},
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      debugPrint('Error in getTopHeadlines: ${e.message}');
      rethrow;
    }
  }

  // [Other methods follow the same pattern...]
  Future<Map<String, dynamic>> searchNews({
  required String query,
  CancelToken? cancelToken, // ← أضف هذا
}) async {
  final response = await _dio.get(
    '$_baseUrl/everything',
    queryParameters: {
      'q': query,
      'apiKey': _apiKey,
    },
    cancelToken: cancelToken, // ← مرّره هنا
  );
  return response.data;
}

Future<Map<String, dynamic>> getNewsByCategory({
  required String category,
  int page = 1,
  int pageSize = 20,
}) async {
  final response = await _dio.get(
    '$_baseUrl/top-headlines',
    queryParameters: {
      'category': category,
      'page': page,
      'pageSize': pageSize,
      'country': 'us', // أو اجعلها باراميتر إذا أردت
      'apiKey': _apiKey,
    },
  );
  return response.data;
}

}

// Cache Interceptor
class _CacheInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  _CacheInterceptor(this._prefs);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final cacheKey = options.extra['cacheKey'] as String?;
    final cacheDuration = options.extra['cacheDuration'] as Duration?;

    if (cacheKey != null && cacheDuration != null) {
      final cached = _prefs.getString(cacheKey);
      if (cached != null) {
        final decoded = json.decode(cached);
        final timestamp = decoded['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp < cacheDuration.inMilliseconds) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: decoded['data'],
              statusCode: 200,
            ),
            true, // Return cached response immediately
          );
        }
        await _prefs.remove(cacheKey);
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final cacheKey = response.requestOptions.extra['cacheKey'] as String?;
    if (cacheKey != null && response.statusCode == 200) {
      await _prefs.setString(
        cacheKey,
        json.encode({
          'data': response.data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    }
    handler.next(response);
  }
}

// Retry Interceptor
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Get current retry count from extra
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;
    
    if (_shouldRetry(err) && retryCount < maxRetries) {
      // Calculate delay with exponential backoff
      final delay = Duration(seconds: 1 * (retryCount + 1));
      await Future.delayed(delay);
      
      // Update retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      try {
        // Retry the request
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with the error
        handler.next(err);
        return;
      }
    }
    
    // No more retries, continue with the error
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.response?.statusCode == 429; // Rate limit
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      err = err.copyWith(
        message: err.response?.data['message'] ?? err.message,
      );
    }
    handler.next(err);
  }
}

// Extension for retry count
extension RequestOptionsX on RequestOptions {
  static const _retryCountKey = 'retryCount';

  int? get _retryCount => extra[_retryCountKey] as int?;
  set _retryCount(int? value) => extra[_retryCountKey] = value;
}