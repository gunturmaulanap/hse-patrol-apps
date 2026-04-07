import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/env/app_env.dart';
import '../error/error_handler.dart';
import '../storage/session_manager.dart';
import '../utils/logger.dart';
import 'api_response.dart';

class DioClient {
  DioClient._();

  static bool _interceptorsInitialized = false;
  static bool _isRefreshing = false;

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: AppEnv.connectTimeout,
      receiveTimeout: AppEnv.receiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  static Future<void> initInterceptors() async {
    if (_interceptorsInitialized) return;

    final sessionManager = SessionManager();

    instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          log.apiRequest(
            options.method,
            options.path,
            queryParams: options.queryParameters,
            body: options.data,
          );

          // Add authorization token if available
          final token = await sessionManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          log.apiResponse(
            error.requestOptions.method,
            error.requestOptions.path,
            error.response?.statusCode ?? 0,
          );

          // Handle 401 - Try to refresh token
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            try {
              // Attempt to refresh token
              final refreshed = await _attemptTokenRefresh();

              if (refreshed) {
                _isRefreshing = false;

                // Retry the original request with new token
                final opts = error.requestOptions;
                final token = await sessionManager.getToken();
                if (token != null) {
                  opts.headers['Authorization'] = 'Bearer $token';
                }

                final retryResponse = await instance.fetch(opts);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              log.error('Token refresh failed', error: e);
            } finally {
              _isRefreshing = false;
            }

            // If refresh failed, clear session and let user logout
            await sessionManager.clearToken();
            await sessionManager.clearRole();
          }

          // Convert DioException to AppException
          final appException = ErrorHandler.handleDioException(error);

          // Log the error
          log.exception(
            'API Error',
            appException,
            tag: error.requestOptions.path,
          );

          // Return error with user-friendly message
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: appException,
              type: error.type,
            ),
          );
        },
        onResponse: (response, handler) {
          log.apiResponse(
            response.requestOptions.method,
            response.requestOptions.path,
            response.statusCode ?? 0,
            data: response.data,
          );

          // Validate response format
          final validatedResponse = ApiResponse.validate(response);
          return handler.next(validatedResponse);
        },
      ),
    );

    _interceptorsInitialized = true;
  }

  /// Attempt to refresh the access token
  static Future<bool> _attemptTokenRefresh() async {
    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      // Call refresh token endpoint
      final response = await instance.post(
        '/refresh-token',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? response.data['data'] as Map<String, dynamic>?
            : response.data as Map<String, dynamic>?;

        final newToken = data?['token']?.toString() ?? data?['access_token']?.toString();

        if (newToken != null && newToken.isNotEmpty) {
          await sessionManager.saveToken(newToken);
          log.info('Token refreshed successfully');
          return true;
        }
      }

      return false;
    } catch (e) {
      log.error('Failed to refresh token', error: e);
      return false;
    }
  }

  /// Helper method for GET requests
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Helper method for POST requests
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Helper method for PUT requests
  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Helper method for PATCH requests
  static Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Helper method for DELETE requests
  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }
}
