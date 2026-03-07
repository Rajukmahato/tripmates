/// Custom exception classes for better error handling
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when API returns 401 Unauthorized
class UnauthorizedException extends AppException {
  UnauthorizedException({String message = "Unauthorized access"})
    : super(message);
}

/// Thrown when API returns 403 Forbidden
class ForbiddenException extends AppException {
  ForbiddenException({String message = "Access forbidden"}) : super(message);
}

/// Thrown when API returns 404 Not Found
class NotFoundException extends AppException {
  NotFoundException({String message = "Resource not found"}) : super(message);
}

/// Thrown when API returns 400 Bad Request
class BadRequestException extends AppException {
  BadRequestException({String message = "Bad request"}) : super(message);
}

/// Thrown when API returns 500+ Server Error
class ServerException extends AppException {
  final int? statusCode;

  ServerException({String message = "Server error", this.statusCode})
    : super(message);
}

/// Thrown when network is unavailable
class NetworkException extends AppException {
  NetworkException({String message = "No internet connection"})
    : super(message);
}

/// Thrown when request times out
class TimeoutException extends AppException {
  TimeoutException({String message = "Request timeout"}) : super(message);
}

/// Thrown when Hive database operations fail
class CacheException extends AppException {
  CacheException({String message = "Cache operation failed"}) : super(message);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  ValidationException({String message = "Validation failed"}) : super(message);
}

/// Thrown when token operations fail
class TokenException extends AppException {
  TokenException({String message = "Token operation failed"}) : super(message);
}

/// Thrown when file operations fail
class FileException extends AppException {
  FileException({String message = "File operation failed"}) : super(message);
}

/// Generic exception for unexpected errors
class UnexpectedException extends AppException {
  UnexpectedException({String message = "An unexpected error occurred"})
    : super(message);
}
