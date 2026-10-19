import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';

void main() {
  group('AuthFormController', () {
    late _ControlledAuth auth;
    late ProviderContainer container;

    setUp(() {
      auth = _ControlledAuth();
      container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      )..listen(loginFormProvider, (_, _) {});
    });

    AuthFormState state() => container.read(loginFormProvider);
    AuthFormController controller() =>
        container.read(loginFormProvider.notifier);

    test('marks the request as pending, then succeeds', () async {
      final result = controller().signInWithGoogle();
      expect(state().pending, AuthMethod.google);
      expect(state().isBusy, isTrue);

      auth.complete();

      expect(await result, isTrue);
      expect(state().isBusy, isFalse);
      expect(state().failure, isNull);
    });

    test('records why a request failed', () async {
      final result = controller().signIn(email: 'a@b.co', password: 'x');
      auth.fail(AuthFailure.invalidCredentials);

      expect(await result, isFalse);
      expect(state().failure, AuthFailure.invalidCredentials);
      expect(state().isBusy, isFalse);
    });

    test('turns unexpected exceptions into an unknown failure', () async {
      final result = controller().signInWithFacebook();
      auth.completer.completeError(Exception('boom'));

      expect(await result, isFalse);
      expect(state().failure, AuthFailure.unknown);
    });

    test('ignores a second request while one is running', () async {
      final first = controller().signInWithGoogle();
      final second = controller().signInWithFacebook();

      expect(await second, isFalse);
      expect(state().pending, AuthMethod.google);

      auth.complete();
      expect(await first, isTrue);
    });

    test('a new attempt clears the previous failure', () async {
      final first = controller().signInWithGoogle();
      auth.fail(AuthFailure.network);
      await first;

      auth = auth.next();
      unawaited(controller().signInWithGoogle());

      expect(state().failure, isNull);
    });
  });
}

/// Auth whose requests finish only when the test says so.
class _ControlledAuth extends FakeAuthRepository {
  _ControlledAuth() : super(latency: Duration.zero);

  Completer<AuthUser> completer = Completer();

  _ControlledAuth next() => this..completer = Completer();

  void complete() =>
      completer.complete(const AuthUser(id: '1', email: 'a@b.co'));

  void fail(AuthFailure failure) =>
      completer.completeError(AuthException(failure));

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => completer.future;

  @override
  Future<AuthUser> signInWithGoogle() => completer.future;

  @override
  Future<AuthUser> signInWithFacebook() => completer.future;
}
