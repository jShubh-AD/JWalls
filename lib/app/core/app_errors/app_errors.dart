class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  const NoInternetException() : super("No internet connection. Please check your network.");
}

class TimeoutException extends AppException {
  const TimeoutException() : super("Connection timed out. Please try again.");
}

class RequestCancelledException extends AppException {
  const RequestCancelledException() : super("Request was cancelled.");
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super("Invalid API credentials. Access unauthorized.");
}

class RateLimitException extends AppException {
  const RateLimitException() : super("You have exceeded your limit for this hour. Please try again in an hour.");
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ServerException extends AppException {
  final int code;
  const ServerException(this.code, [String message = "Server error occurred. Please try later."]) : super(message, statusCode: code);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}