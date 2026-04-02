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
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.surface,
        duration: duration,
        behavior: behavior,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: '✕',
          textColor: textColor ?? AppColors.textPrimary,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Icon close hitam agar kontras dengan background hijau muda
    show(
      context,
      message: message,
      backgroundColor: AppColors.statusApproved,
      duration: duration,
      textColor: Colors.black,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Icon close putih agar kontras dengan background merah gelap
    show(
      context,
      message: message,
      backgroundColor: Colors.red.shade800,
      duration: duration,
      textColor: Colors.white,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Icon close putih agar kontras dengan background kuning/oranye
    show(
      context,
      message: message,
      backgroundColor: AppColors.statusRejected,
      duration: duration,
      textColor: Colors.black,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Icon close putih agar kontras dengan background biru
    show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      duration: duration,
      textColor: Colors.white,
    );
  }
}
