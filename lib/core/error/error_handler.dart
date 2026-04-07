import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Global error handler for consistent error handling across the app
class ErrorHandler {
  /// Parse DioException and convert to appropriate AppException
  static AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.requestTimeout(originalError: error);

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error);

      case DioExceptionType.cancel:
        return NetworkException.unknown(
          originalError: error,
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.error is SocketException) {
          return NetworkException.noInternet(originalError: error);
        }
        return NetworkException.unknown(originalError: error);

      default:
        return NetworkException.unknown(originalError: error);
    }
  }

  /// Handle HTTP status codes
  static AppException _handleStatusCode(int? statusCode, DioException error) {
    switch (statusCode) {
      case 400:
        return _handleBadRequest(error);

      case 401:
        return NetworkException.unauthorized(originalError: error);

      case 403:
        return NetworkException.forbidden(originalError: error);

      case 404:
        return NetworkException.notFound(originalError: error);

      case 422:
        return _handleValidationException(error);

      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkException.serverError(
          statusCode: statusCode,
          originalError: error,
        );

      default:
        return NetworkException.unknown(originalError: error);
    }
  }

  /// Handle 400 Bad Request
  static AppException _handleBadRequest(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null) {
          return ValidationException.invalidInput(
            message: message,
            originalError: error,
          );
        }
      }
      return ValidationException.invalidInput(originalError: error);
    } catch (_) {
      return ValidationException.invalidInput(originalError: error);
    }
  }

  /// Handle 422 Validation Error
  static AppException _handleValidationException(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        final errors = data['errors'] as Map<String, dynamic>?;

        // Format error messages
        String formattedMessage = message ?? 'Validasi data gagal.';
        if (errors != null && errors.isNotEmpty) {
          final errorDetails = StringBuffer('$formattedMessage\n\n');
          errors.forEach((key, value) {
            if (value is List) {
              errorDetails.writeln('• ${value.join(", ")}');
            } else if (value is String) {
              errorDetails.writeln('• $value');
            }
          });
          formattedMessage = errorDetails.toString().trim();
        }

        return ValidationException.invalidInput(
          message: formattedMessage,
          fieldErrors: _parseFieldErrors(errors),
          originalError: error,
        );
      }
      return ValidationException.invalidInput(originalError: error);
    } catch (_) {
      return ValidationException.invalidInput(originalError: error);
    }
  }

  /// Parse field errors from backend response
  static Map<String, List<String>>? _parseFieldErrors(dynamic errors) {
    if (errors == null) return null;
    if (errors is! Map) return null;

    final Map<String, List<String>> fieldErrors = {};
    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      }
    });

    return fieldErrors;
  }

  /// Handle generic exceptions
  static AppException handleException(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return handleDioException(error);
    }

    // Handle other exception types
    if (error is TypeError) {
      return BusinessException.invalidOperation(
        message: 'Terjadi kesalahan pada aplikasi.',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return ValidationException.invalidInput(
        message: 'Format data tidak valid.',
        originalError: error,
      );
    }

    // Default fallback
    return NetworkException.unknown(originalError: error);
  }

  /// Extract user-friendly error message
  static String getUserMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is DioException) {
      return handleDioException(error).message;
    }

    return error.toString().replaceAll('Exception: ', '');
  }

  /// Extract error code for logging/analytics
  static String? getErrorCode(Object error) {
    if (error is AppException) {
      return error.code;
    }

    if (error is DioException) {
      return handleDioException(error).code;
    }

    return null;
  }
}

/// Type alias for FormatException (dart:core)
class FormatException implements Exception {
  final String message;
  FormatException(this.message);
  @override
  String toString() => message;
}
