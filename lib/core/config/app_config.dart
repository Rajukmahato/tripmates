/// Application configuration for different environments
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Socket.io Configuration
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Feature Flags
  static const bool enableSocketReconnection = true;
  static const int socketReconnectionAttempts = 5;
  static const int socketReconnectionDelay = 2000; // milliseconds

  // API Timeouts
  static const int apiConnectionTimeout = 30000; // 30 seconds
  static const int apiReceiveTimeout = 30000; // 30 seconds

  // Cache Configuration
  static const int cacheExpirationDays = 7;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Upload
  static const int maxImageSizeMB = 10;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Chat Configuration
  static const int maxMessageLength = 5000;
  static const int typingIndicatorDebounceMs = 2000;
  static const int messageLoadLimit = 50;

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
}
