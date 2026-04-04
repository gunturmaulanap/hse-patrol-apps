import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color? textColor,
    bool showAction = true, // NEW: Parameter untuk mengontrol action button
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    // Build snackbar
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? AppColors.surface,
      duration: duration,
      behavior: behavior,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Hanya tampilkan action jika showAction = true
      action: showAction
          ? SnackBarAction(
              label: '✕',
              textColor: textColor ?? AppColors.textPrimary,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            )
          : null,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool showAction = false, // Default false agar auto-dismiss
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.statusApproved,
      duration: duration,
      textColor: Colors.black,
      showAction: showAction,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool showAction = false, // Default false agar auto-dismiss
  }) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red.shade800,
      duration: duration,
      textColor: Colors.white,
      showAction: showAction,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool showAction = false, // Default false agar auto-dismiss
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.statusRejected,
      duration: duration,
      textColor: Colors.black,
      showAction: showAction,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool showAction = false, // Default false agar auto-dismiss
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      duration: duration,
      textColor: Colors.white,
      showAction: showAction,
    );
  }
}
