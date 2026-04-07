/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory NetworkException.requestTimeout({dynamic originalError}) {
    return NetworkException(
      message: 'Koneksi timeout. Silakan coba lagi.',
      code: 'REQUEST_TIMEOUT',
      originalError: originalError,
    );
  }

  factory NetworkException.noInternet({dynamic originalError}) {
    return NetworkException(
      message: 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.',
      code: 'NO_INTERNET',
      originalError: originalError,
    );
  }

  factory NetworkException.serverError({int? statusCode, dynamic originalError}) {
    return NetworkException(
      message: 'Server sedang bermasalah. Silakan coba lagi nanti.',
      code: 'SERVER_ERROR_$statusCode',
      originalError: originalError,
    );
  }

  factory NetworkException.unauthorized({dynamic originalError}) {
    return NetworkException(
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      code: 'UNAUTHORIZED',
      originalError: originalError,
    );
  }

  factory NetworkException.forbidden({dynamic originalError}) {
    return NetworkException(
      message: 'Anda tidak memiliki akses untuk melakukan aksi ini.',
      code: 'FORBIDDEN',
      originalError: originalError,
    );
  }

  factory NetworkException.notFound({dynamic originalError}) {
    return NetworkException(
      message: 'Data tidak ditemukan.',
      code: 'NOT_FOUND',
      originalError: originalError,
    );
  }

  factory NetworkException.unknown({dynamic originalError}) {
    return NetworkException(
      message: 'Terjadi kesalahan jaringan. Silakan coba lagi.',
      code: 'NETWORK_UNKNOWN',
      originalError: originalError,
    );
  }
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory AuthException.invalidCredentials({dynamic originalError}) {
    return AuthException(
      message: 'Email atau password salah.',
      code: 'INVALID_CREDENTIALS',
      originalError: originalError,
    );
  }

  factory AuthException.sessionExpired({dynamic originalError}) {
    return AuthException(
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      code: 'SESSION_EXPIRED',
      originalError: originalError,
    );
  }

  factory AuthException.notAuthenticated({dynamic originalError}) {
    return AuthException(
      message: 'Anda belum login. Silakan login terlebih dahulu.',
      code: 'NOT_AUTHENTICATED',
      originalError: originalError,
    );
  }

  factory AuthException.tokenRefreshFailed({dynamic originalError}) {
    return AuthException(
      message: 'Gagal memperbarui sesi. Silakan login kembali.',
      code: 'TOKEN_REFRESH_FAILED',
      originalError: originalError,
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory ValidationException.invalidInput({
    String message = 'Data yang Anda masukkan tidak valid.',
    Map<String, List<String>>? fieldErrors,
    dynamic originalError,
  }) {
    return ValidationException(
      message: message,
      code: 'VALIDATION_ERROR',
      fieldErrors: fieldErrors,
      originalError: originalError,
    );
  }

  factory ValidationException.requiredField({
    required String fieldName,
    dynamic originalError,
  }) {
    return ValidationException(
      message: '$fieldName harus diisi.',
      code: 'REQUIRED_FIELD',
      originalError: originalError,
    );
  }

  factory ValidationException.invalidFormat({
    required String fieldName,
    dynamic originalError,
  }) {
    return ValidationException(
      message: 'Format $fieldName tidak valid.',
      code: 'INVALID_FORMAT',
      originalError: originalError,
    );
  }
}

/// Business logic exceptions
class BusinessException extends AppException {
  const BusinessException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory BusinessException.taskNotFound({dynamic originalError}) {
    return const BusinessException(
      message: 'Tugas tidak ditemukan.',
      code: 'TASK_NOT_FOUND',
    );
  }

  factory BusinessException.areaNotFound({dynamic originalError}) {
    return const BusinessException(
      message: 'Area tidak ditemukan.',
      code: 'AREA_NOT_FOUND',
    );
  }

  factory BusinessException.invalidOperation({
    required String message,
    dynamic originalError,
  }) {
    return BusinessException(
      message: message,
      code: 'INVALID_OPERATION',
      originalError: originalError,
    );
  }
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory StorageException.readFailed({dynamic originalError}) {
    return const StorageException(
      message: 'Gagal membaca data dari penyimpanan.',
      code: 'STORAGE_READ_FAILED',
    );
  }

  factory StorageException.writeFailed({dynamic originalError}) {
    return const StorageException(
      message: 'Gagal menyimpan data.',
      code: 'STORAGE_WRITE_FAILED',
    );
  }

  factory StorageException.deleteFailed({dynamic originalError}) {
    return const StorageException(
      message: 'Gagal menghapus data.',
      code: 'STORAGE_DELETE_FAILED',
    );
  }
}
