import 'package:flutter/material.dart';
import '../error/app_exception.dart';
import 'logger.dart';

/// Helper utilities for error handling in UI
class ErrorUtils {
  /// Show error dialog with user-friendly message
  static void showErrorDialog(
    BuildContext context,
    Object error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    final message = error is AppException
        ? error.message
        : 'Terjadi kesalahan. Silakan coba lagi.';
    final code = error is AppException ? error.code : null;

    log.error('Showing error dialog', error: error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Terjadi Kesalahan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Kode: $code',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context,
    Object error,
  ) {
    final message = error is AppException
        ? error.message
        : 'Terjadi kesalahan. Silakan coba lagi.';
    log.error('Showing error snackbar', error: error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Get appropriate icon for exception type
  static IconData getIconForException(Object error) {
    if (error is NetworkException) {
      switch (error.code) {
        case 'NO_INTERNET':
          return Icons.wifi_off;
        case 'REQUEST_TIMEOUT':
          return Icons.access_time;
        case 'UNAUTHORIZED':
          return Icons.lock;
        case 'FORBIDDEN':
          return Icons.block;
        default:
          return Icons.cloud_off;
      }
    }

    if (error is AuthException) {
      return Icons.lock_outline;
    }

    if (error is ValidationException) {
      return Icons.error_outline;
    }

    if (error is BusinessException) {
      return Icons.business_center;
    }

    return Icons.error;
  }

  /// Get appropriate color for exception type
  static Color getColorForException(BuildContext context, Object error) {
    if (error is NetworkException) {
      return Colors.orange;
    }

    if (error is AuthException) {
      return Colors.red;
    }

    if (error is ValidationException) {
      return Colors.amber;
    }

    if (error is BusinessException) {
      return Colors.blue;
    }

    return Colors.grey;
  }

  /// Handle error and show appropriate UI
  static void handleError(
    BuildContext context,
    Object error, {
    bool showDialog = false,
    VoidCallback? onRetry,
  }) {
    if (showDialog) {
      showErrorDialog(context, error, onRetry: onRetry);
    } else {
      showErrorSnackbar(context, error);
    }
  }
}

/// Extension to make error handling easier
extension ErrorHandlingExtension on BuildContext {
  void showError(
    Object error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    ErrorUtils.showErrorDialog(this, error, title: title, onRetry: onRetry);
  }

  void showErrorSnackbar(Object error) {
    ErrorUtils.showErrorSnackbar(this, error);
  }
}
