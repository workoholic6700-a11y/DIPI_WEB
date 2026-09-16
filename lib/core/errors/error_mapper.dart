import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Translates any thrown error into a typed [Failure].
///
/// Centralizing this means every repository maps errors identically and the
/// mapping logic lives in exactly one place.
Failure mapError(Object error, [StackTrace? _]) {
  switch (error) {
    case Failure f:
      return f;
    case AuthException e:
      return AuthFailure(_friendlyAuth(e.message), cause: e);
    case PostgrestException e:
      // 42501 = insufficient privilege (RLS denied). 23505 = unique violation.
      if (e.code == '42501' || e.code == 'PGRST301') {
        return PermissionFailure(cause: e);
      }
      if (e.code == 'PGRST116') return NotFoundFailure(cause: e);
      return UnexpectedFailure(cause: e, message: e.message);
    case StorageException e:
      return StorageFailure(e.message, cause: e);
    case SocketException _:
    case TimeoutException _:
      return NetworkFailure(cause: error);
    default:
      return UnexpectedFailure(cause: error);
  }
}

String _friendlyAuth(String raw) {
  final m = raw.toLowerCase();
  if (m.contains('invalid login')) {
    return 'That email or password doesn\'t look right.';
  }
  if (m.contains('email not confirmed')) {
    return 'Please confirm your email first.';
  }
  if (m.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  return raw;
}
