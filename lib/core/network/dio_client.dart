import 'package:dio/dio.dart';

import '../../app/env/app_env.dart';
import '../storage/session_manager.dart';

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
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            // Token expired or invalid, clear session
            await sessionManager.clearToken();
            await sessionManager.clearRole();
          }
          return handler.next(error);
        },
      ),
    );

    _interceptorsInitialized = true;
  }
}
