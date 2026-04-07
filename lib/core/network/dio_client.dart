import 'package:dio/dio.dart';

import '../../app/env/app_env.dart';
import '../storage/session_manager.dart';
import '../utils/logger.dart';

class DioClient {
  DioClient._();

  static bool _interceptorsInitialized = false;

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

  /// Helper to check if data is FormData
  static bool _isFormData(dynamic data) {
    return data is FormData;
  }

  static Future<void> initInterceptors() async {
    if (_interceptorsInitialized) return;

    final sessionManager = SessionManager();

    instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = await sessionManager.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            log.debug(
              'Authorization header attached',
              data: {
                'method': options.method,
                'path': options.path,
                'hasToken': true,
              },
              tag: 'DioClient',
            );
          } else {
            log.warning(
              'No authorization token available',
              data: {
                'method': options.method,
                'path': options.path,
                'hasToken': false,
              },
              tag: 'DioClient',
            );
          }

          // Log request WITHOUT accessing data directly (data might be FormData)
          final body = options.data;
          if (_isFormData(body)) {
            log.apiRequestWithData(
              options.method,
              options.path,
              queryParams: options.queryParameters,
              body: '<FormData with ${body.files.length} files>',
            );
          } else {
            log.apiRequest(
              options.method,
              options.path,
              queryParams: options.queryParameters,
              body: body,
            );
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final request = error.requestOptions;

          log.warning(
            'HTTP error intercepted',
            data: {
              'statusCode': statusCode,
              'method': request.method,
              'path': request.path,
            },
            tag: 'DioClient',
          );

          // Handle token expiration
          if (statusCode == 401) {
            // Token expired or invalid, clear session
            await sessionManager.clearToken();
            await sessionManager.clearRole();

            log.warning(
              'Session cleared after 401 response',
              data: {
                'method': request.method,
                'path': request.path,
              },
              tag: 'DioClient',
            );
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          // Log response WITHOUT accessing data in a way that breaks FormData
          log.apiResponse(
            response.requestOptions.method,
            response.requestOptions.path,
            response.statusCode ?? 0,
            data: response.data,
          );

          return handler.next(response);
        },
      ),
    );

    _interceptorsInitialized = true;
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
