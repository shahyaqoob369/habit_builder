/// Why an authentication request failed, independent of the backend.
enum AuthFailure {
  /// Wrong email or password. Kept vague on purpose, so it doesn't reveal
  /// which emails have accounts.
  invalidCredentials,

  /// Sign up with an email that already has an account.
  emailAlreadyInUse,

  /// No connection, or the server couldn't be reached.
  network,

  /// Too many failed attempts; the server blocks this device for a while.
  tooManyAttempts,

  /// Deleting the account needs the password again (or a fresh sign-in).
  requiresRecentLogin,

  /// The sign-in method isn't connected yet (Google and Facebook until
  /// plan steps 16 and 17).
  unavailable,

  /// The user closed the Google or Facebook sign-in. Not shown as an error.
  cancelled,

  unknown,
}

/// Thrown by `AuthRepository` methods.
class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}
