import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Using system font to avoid network dependency issues
  static TextStyle get baseTextStyle => const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => baseTextStyle.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
      );

  static TextStyle get h3 => baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body1 => baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get body1Inverted =>
      body1.copyWith(color: AppColors.textInverted);
  static TextStyle get h3Inverted =>
      h3.copyWith(color: AppColors.textInverted);

  static TextTheme get textTheme => TextTheme(
        headlineMedium: h1,
        titleLarge: h3,
        bodyLarge: body1,
        bodyMedium: caption,
        bodySmall: caption.copyWith(fontSize: 12),
      );
}
