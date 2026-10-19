import 'package:flutter/foundation.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';

/// What the Sign Up form collects.
@immutable
class SignUpDetails {
  const SignUpDetails({
    required this.name,
    required this.email,
    required this.password,
    required this.keepSignedIn,
    required this.marketingOptIn,
  });

  final String name;
  final String email;
  final String password;

  /// Stay signed in on this device after the app restarts.
  final bool keepSignedIn;

  /// Consent to emails about pricing and offers.
  final bool marketingOptIn;
}

/// Authentication backend. The UI talks only to this interface: a fake
/// implementation for now, Firebase from plan step 14.
///
/// Every method throws an `AuthException` on failure.
abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUp(SignUpDetails details);

  /// Sends a reset link if [email] has an account. Succeeds either way, so
  /// the screen can't be used to find out which emails are registered.
  Future<void> sendPasswordResetEmail(String email);

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithFacebook();

  Future<void> signOut();
}
