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

/// The result of a Google or Apple sign-in. `isNewUser` is true
/// when it created the account (logged as a sign-up).
typedef SocialSignIn = ({AuthUser user, bool isNewUser});

/// Authentication backend. The UI talks only to this interface:
/// `FirebaseAuthRepository` in the app, `FakeAuthRepository` in tests.
///
/// Every method throws an `AuthException` on failure.
abstract interface class AuthRepository {
  AuthUser? get currentUser;

  /// The signed-in user (or null), now and after every change.
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUp(SignUpDetails details);

  /// Sends a reset link if [email] has an account. Succeeds either way, so
  /// the screen can't be used to find out which emails are registered.
  Future<void> sendPasswordResetEmail(String email);

  Future<SocialSignIn> signInWithGoogle();

  /// Sign in with Apple (iOS only).
  Future<SocialSignIn> signInWithApple();

  Future<void> signOut();

  /// Deletes the signed-in account and its data, then signs out. Required
  /// in-app by App Store guideline 5.1.1(v). Accounts with a password
  /// must confirm it ([AuthUser.hasPassword]); Google and Apple accounts
  /// confirm by signing in with them again.
  Future<void> deleteAccount({String? password});

  /// Changes the signed-in user's display name.
  Future<AuthUser> updateName(String name);
}
