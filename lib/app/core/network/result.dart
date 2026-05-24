abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}


class NetworkFailure extends Failure {
  const NetworkFailure() : super("No internet connection. Please check your network.");
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super("Connection timed out. Please try again.");
}

class RateLimitFailure extends Failure {
  const RateLimitFailure() : super("You have exceeded your limit for this hour. Please try again in an hour.");
}

class AuthFailure extends Failure {
  const AuthFailure() : super("Access unauthorized. Invalid API credentials.");
}

class ServerFailure extends Failure {
  const ServerFailure([String message = "Server error occurred. Please try later."]) : super(message);
}

class ParserFailure extends Failure {
  const ParserFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

sealed class Result<S, F extends Failure> {
  const Result();

  // Pattern matching helpers (optional, but very clean)
  R fold<R>({
    required R Function(S success) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is Success<S, F>) {
      return onSuccess((this as Success<S, F>).value);
    } else if (this is FailureResult<S, F>) {
      return onFailure((this as FailureResult<S, F>).failure);
    }
    throw StateError("Unknown Result type: $this");
  }
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S value;
  const Success(this.value);
}

class FailureResult<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const FailureResult(this.failure);
}
