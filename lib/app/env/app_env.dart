class AppEnv {
  static const String appName = 'HSE Aksamala';
  static const String baseUrl = 'https://mes.aksamala.co.id/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const bool enableRouteLogging = false;

  // Enable detailed logging in debug mode, disable in production
  static const bool enableLogging = bool.fromEnvironment('DEBUG', defaultValue: true);

  // API Configuration
  static const int maxPaginationPages = 10; // Prevent infinite pagination
  static const int defaultPaginationPageSize = 100; // Backend limit: max 100 per page
  static const int maxPhotosPerTask = 3;

  // Security
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}