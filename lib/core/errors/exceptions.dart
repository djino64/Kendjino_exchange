// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, [this.statusCode]);
  @override String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
  @override String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => 'AuthException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override String toString() => 'StorageException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override String toString() => 'ValidationException: $message';
}

class InsufficientFundsException implements Exception {
  final double available;
  final double required;
  const InsufficientFundsException({required this.available, required this.required});
  @override String toString() =>
      'InsufficientFundsException: need $required, have $available';
}

class LimitExceededException implements Exception {
  final String message;
  const LimitExceededException(this.message);
  @override String toString() => 'LimitExceededException: $message';
}