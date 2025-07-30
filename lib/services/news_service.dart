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

    
    _dio.interceptors.addAll([
      _CacheInterceptor(_prefs),
      RetryInterceptor(dio: _dio),
      _ErrorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  
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

 
  Future<Map<String, dynamic>> searchNews({
  required String query,
  CancelToken? cancelToken, 
}) async {
  final response = await _dio.get(
    '$_baseUrl/everything',
    queryParameters: {
      'q': query,
      'apiKey': _apiKey,
    },
    cancelToken: cancelToken, 
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
      'country': 'us', 
      'apiKey': _apiKey,
    },
  );
  return response.data;
}

}


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
            true, 
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
    
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;
    
    if (_shouldRetry(err) && retryCount < maxRetries) {
      
      final delay = Duration(seconds: 1 * (retryCount + 1));
      await Future.delayed(delay);
      
      
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      try {
        
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        
        handler.next(err);
        return;
      }
    }
    
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.response?.statusCode == 429; // Rate limit
  }
}


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


extension RequestOptionsX on RequestOptions {
  static const _retryCountKey = 'retryCount';

  int? get _retryCount => extra[_retryCountKey] as int?;
  set _retryCount(int? value) => extra[_retryCountKey] = value;
}