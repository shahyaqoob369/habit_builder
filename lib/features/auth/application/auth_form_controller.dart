import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';

/// The ways a form can sign the user in; each has its own loading spinner.
enum AuthMethod { email, google, facebook }

/// Submission state of one auth screen.
@immutable
class AuthFormState {
  const AuthFormState({this.pending, this.failure});

  /// The request in flight, if any.
  final AuthMethod? pending;

  /// Why the last request failed. Cleared when a new one starts.
  final AuthFailure? failure;

  bool get isBusy => pending != null;
}

/// Runs an auth screen's requests and tracks their state.
///
/// Each method returns whether it succeeded, so the screen can move on;
/// failures land in [AuthFormState.failure] for the screen to show.
class AuthFormController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signIn({required String email, required String password}) {
    return _run(
      AuthMethod.email,
      () => _repository.signInWithEmail(
        email: email.trim(),
        password: password,
      ),
      success: AnalyticsEvent.login(AuthMethod.email.name),
    );
  }

  Future<bool> signUp(SignUpDetails details) => _run(
    AuthMethod.email,
    () => _repository.signUp(details),
    success: AnalyticsEvent.signUp(AuthMethod.email.name),
  );

  Future<bool> sendPasswordReset(String email) => _run(
    AuthMethod.email,
    () => _repository.sendPasswordResetEmail(email.trim()),
  );

  // Logged as log-ins: whether the account is new is only known once
  // Firebase Auth is connected (plan step 16).
  Future<bool> signInWithGoogle() => _run(
    AuthMethod.google,
    _repository.signInWithGoogle,
    success: AnalyticsEvent.login(AuthMethod.google.name),
  );

  Future<bool> signInWithFacebook() => _run(
    AuthMethod.facebook,
    _repository.signInWithFacebook,
    success: AnalyticsEvent.login(AuthMethod.facebook.name),
  );

  Future<bool> _run(
    AuthMethod method,
    Future<Object?> Function() request, {
    AnalyticsEvent? success,
  }) async {
    // One request at a time: ignore taps while one is running.
    if (state.isBusy) return false;
    // Read now: the screen may close (and dispose this) while waiting.
    final analytics = ref.read(analyticsProvider);
    state = AuthFormState(pending: method);
    AuthFailure? failure;
    try {
      await request();
    } on AuthException catch (error) {
      failure = error.failure;
    } on Exception {
      failure = AuthFailure.unknown;
    } finally {
      // Also runs when an unexpected error escapes, so the screen never
      // stays busy. Skipped if the screen was closed in the meantime.
      if (ref.mounted) state = AuthFormState(failure: failure);
    }
    if (failure == null && success != null) {
      unawaited(analytics.logEvent(success));
    }
    return ref.mounted && failure == null;
  }
}

final NotifierProvider<AuthFormController, AuthFormState> loginFormProvider =
    NotifierProvider.autoDispose<AuthFormController, AuthFormState>(
      AuthFormController.new,
    );

final NotifierProvider<AuthFormController, AuthFormState> signUpFormProvider =
    NotifierProvider.autoDispose<AuthFormController, AuthFormState>(
      AuthFormController.new,
    );

final NotifierProvider<AuthFormController, AuthFormState>
resetPasswordFormProvider =
    NotifierProvider.autoDispose<AuthFormController, AuthFormState>(
      AuthFormController.new,
    );
