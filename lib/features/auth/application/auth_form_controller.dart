import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    );
  }

  Future<bool> signUp(SignUpDetails details) =>
      _run(AuthMethod.email, () => _repository.signUp(details));

  Future<bool> sendPasswordReset(String email) => _run(
    AuthMethod.email,
    () => _repository.sendPasswordResetEmail(email.trim()),
  );

  Future<bool> signInWithGoogle() =>
      _run(AuthMethod.google, _repository.signInWithGoogle);

  Future<bool> signInWithFacebook() =>
      _run(AuthMethod.facebook, _repository.signInWithFacebook);

  Future<bool> _run(
    AuthMethod method,
    Future<Object?> Function() request,
  ) async {
    // One request at a time: ignore taps while one is running.
    if (state.isBusy) return false;
    state = AuthFormState(pending: method);
    AuthFailure? failure;
    try {
      await request();
    } on AuthException catch (error) {
      failure = error.failure;
    } on Exception {
      failure = AuthFailure.unknown;
    }
    // The screen may have been closed in the meantime.
    if (!ref.mounted) return false;
    state = AuthFormState(failure: failure);
    return failure == null;
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
