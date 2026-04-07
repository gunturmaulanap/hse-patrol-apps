import 'package:flutter/foundation.dart';
import '../error/app_exception.dart';

import '../app/env/app_env.dart';

/// Application logger with configurable log levels
class AppLogger {
  // Singleton pattern
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  /// Log debug message (only in debug mode)
  void debug(String message, {Map<String, dynamic>? data, String? tag}) {
    if (AppEnv.enableLogging) {
      final taggedMessage = tag != null ? '[$tag] $message' : message;
      if (data != null) {
        debugPrint('$taggedMessage => ${_sanitize(data)}');
      } else {
        debugPrint(taggedMessage);
      }
    }
  }

  /// Log info message
  void info(String message, {Map<String, dynamic>? data, String? tag}) {
    if (AppEnv.enableLogging) {
      final taggedMessage = tag != null ? '[$tag] ℹ️ $message' : 'ℹ️ $message';
      if (data != null) {
        debugPrint('$taggedMessage => ${_sanitize(data)}');
      } else {
        debugPrint(taggedMessage);
      }
    }
  }

  /// Log warning message
  void warning(String message, {Map<String, dynamic>? data, String? tag}) {
    if (AppEnv.enableLogging) {
      final taggedMessage = tag != null ? '[$tag] ⚠️ $message' : '⚠️ $message';
      if (data != null) {
        debugPrint('$taggedMessage => ${_sanitize(data)}');
      } else {
        debugPrint(taggedMessage);
      }
    }
  }

  /// Log error message
  void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (AppEnv.enableLogging) {
      final taggedMessage = tag != null ? '[$tag] ❌ $message' : '❌ $message';
      debugPrint(taggedMessage);

      if (error != null) {
        // Sanitize error message
        final sanitizedError = _sanitizeError(error);
        debugPrint('Error: $sanitizedError');
      }

      if (stackTrace != null && kDebugMode) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log exception (for AppException and other exceptions)
  void exception(
    String message,
    Object exception, {
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (AppEnv.enableLogging) {
      final taggedMessage = tag != null ? '[$tag] 💥 $message' : '💥 $message';
      debugPrint(taggedMessage);

      // Extract error code if AppException
      if (exception is AppException) {
        debugPrint('Code: ${exception.code}');
        debugPrint('Message: ${exception.message}');
      } else {
        final sanitizedError = _sanitizeError(exception);
        debugPrint('Exception: $sanitizedError');
      }

      if (stackTrace != null && kDebugMode) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log API request
  void apiRequest(String method, String endpoint,
      {Map<String, dynamic>? queryParams, Map<String, dynamic>? body}) {
    if (AppEnv.enableLogging) {
      debugPrint('🌐 [$method] $endpoint');
      if (queryParams != null) {
        debugPrint('Query: ${_sanitize(queryParams)}');
      }
      if (body != null) {
        debugPrint('Body: ${_sanitize(body)}');
      }
    }
  }

  /// Log API response
  void apiResponse(String method, String endpoint, int statusCode,
      {dynamic data}) {
    if (AppEnv.enableLogging) {
      debugPrint('📡 [$method] $endpoint => $statusCode');
      if (data != null && kDebugMode) {
        // Only log data in debug mode, not in production
        final sanitized = _sanitizeResponse(data);
        debugPrint('Response: $sanitized');
      }
    }
  }

  /// Sanitize sensitive data from logs
  Map<String, dynamic> _sanitize(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    final sensitiveKeys = [
      'password',
      'token',
      'accessToken',
      'refreshToken',
      'secret',
      'apiKey',
      'authorization',
      'session',
    ];

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (sensitiveKeys.any((sensitive) => key.contains(sensitive))) {
        sanitized[entry.key] = '***REDACTED***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Sanitize error message
  String _sanitizeError(Object error) {
    String errorString = error.toString();

    // Remove sensitive patterns
    final sensitivePatterns = [
      RegExp(r'token["\s:]+["\s]*[^\s"}]+', caseSensitive: false),
      RegExp(r'password["\s:]+["\s]*[^\s"}]+', caseSensitive: false),
      RegExp(r'authorization["\s:]+["\s]*[^\s"}]+', caseSensitive: false),
    ];

    for (final pattern in sensitivePatterns) {
      errorString = errorString.replaceAll(pattern, '***REDACTED***');
    }

    return errorString;
  }

  /// Sanitize API response
  dynamic _sanitizeResponse(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyLower = key.toString().toLowerCase();
        if (keyLower.contains('token') ||
            keyLower.contains('password') ||
            keyLower.contains('secret')) {
          sanitized[key] = '***REDACTED***';
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    }
    return data;
  }
}

/// Extension for easy logging
extension AppLoggerExtension on Object {
  void logDebug(String message, {Map<String, dynamic>? data}) {
    AppLogger.instance.debug(message, data: data, tag: runtimeType.toString());
  }

  void logInfo(String message, {Map<String, dynamic>? data}) {
    AppLogger.instance.info(message, data: data, tag: runtimeType.toString());
  }

  void logWarning(String message, {Map<String, dynamic>? data}) {
    AppLogger.instance.warning(message, data: data, tag: runtimeType.toString());
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.instance.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: runtimeType.toString(),
    );
  }
}

/// Convenience instance
final log = AppLogger.instance;
