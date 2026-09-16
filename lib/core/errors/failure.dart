import 'package:equatable/equatable.dart';

/// A user-safe, typed representation of something going wrong.
///
/// Repositories translate raw exceptions (Postgrest, Storage, Auth, network…)
/// into a [Failure] so the UI layer never has to reason about backend internals
/// and can always show a gentle, human message.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// A gentle, user-facing message.
  final String message;

  /// The original error, retained for logging only.
  final Object? cause;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.cause,
    String message = 'You seem to be offline. Please check your connection.',
  }) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.cause,
    String message = 'You don\'t have permission to do that.',
  }) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.cause,
    String message = 'We couldn\'t find what you were looking for.',
  }) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.cause,
    String message = 'Couldn\'t read saved data.',
  }) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.cause,
    String message = 'Something went wrong. Please try again.',
  }) : super(message);
}
