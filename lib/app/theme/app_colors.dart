import 'package:flutter/material.dart';

class AppColors {
  // Background & Surface
  static const Color background = Color(0xFF000000); // Hitam Pekat
  static const Color surface = Color(0xFF1C1C1E); // Abu-abu gelap untuk Card
  static const Color surfaceLight = Color(0xFF2C2C2E);
  static const Color surfaceVariant = Color(0xFF2C2C2E);

  // Aksen High-Contrast (Modern)
  static const Color primary = Color(0xFFE8FA61); // Kuning Neon
  static const Color primaryLight = Color(0xFFF4FDC4);
  static const Color primaryDark = Color(0xFFA5B71D);
  static const Color secondary = Color(0xFFC5C6FA); // Ungu Pastel
  static const Color secondaryDark = Color(0xFF8B8CE5);
  static const Color tertiary = Color(0xFFFFFFFF); // Putih bersih

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Teks di atas background hitam
  static const Color textInverse = Color(0xFF000000); // Teks di atas aksen kuning/ungu
  static const Color textInverted = textInverse; // Backward compatibility alias
  static const Color textSecondary = Color(0xFFA0A0A5);
  static const Color textHint = Color(0xFF636366);

  // Functional Colors (Status & Risk)
  static const Color statusPending = Color(0xFFC5C6FA);
  static const Color statusApproved = Color(0xFFE8FA61);
  static const Color statusRejected = Color(0xFFFF453A);
  
  static const Color riskCritical = Color(0xFFFF453A);
  static const Color riskHigh = Color(0xFFFF9F0A);
  static const Color riskMedium = Color(0xFFFFD60A);
  static const Color riskLow = Color(0xFF32D74B);

  // Decorative
  static const Color divider = Color(0xFF38383A);
  static const Color border = Color(0xFF38383A);
}
