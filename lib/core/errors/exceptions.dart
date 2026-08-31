/// Base Exception class for the app
abstract class AppException implements Exception {
  final String message;
  final dynamic cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message ${cause != null ? "($cause)" : ""}';
}

/// Thrown when local database operations fail
class AppDatabaseException extends AppException {
  const AppDatabaseException(super.message, [super.cause]);
}

/// Thrown when seed asset reading fails
class AssetReadException extends AppException {
  const AssetReadException(super.message, [super.cause]);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, [super.cause]);
}

/// Thrown when an item is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.cause]);
}
