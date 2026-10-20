import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';

import '../../../helpers/test_preferences.dart';

void main() {
  group('AuthFormController', () {
    late _ControlledAuth auth;
    late RecordingAnalytics analytics;
    late ProviderContainer container;

    setUp(() async {
      auth = _ControlledAuth();
      analytics = RecordingAnalytics();
      container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          analyticsProvider.overrideWithValue(analytics),
          sharedPreferencesProvider.overrideWithValue(
            await createTestPreferences(),
          ),
        ],
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
      expect(analytics.events, [AnalyticsEvent.login('google')]);
    });

    test('records why a request failed', () async {
      final result = controller().signIn(email: 'a@b.co', password: 'x');
      auth.fail(AuthFailure.invalidCredentials);

      expect(await result, isFalse);
      expect(state().failure, AuthFailure.invalidCredentials);
      expect(state().isBusy, isFalse);
      expect(analytics.events, isEmpty);
    });

    test('turns unexpected exceptions into an unknown failure', () async {
      final result = controller().signInWithFacebook();
      auth.completer.completeError(Exception('boom'));

      expect(await result, isFalse);
      expect(state().failure, AuthFailure.unknown);
    });

    test('is never left busy, even after an unexpected error', () async {
      final result = controller().signInWithGoogle();
      auth.completer.completeError(StateError('bug'));

      await expectLater(result, throwsStateError);
      expect(state().isBusy, isFalse);
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

  group('Keep me signed in', () {
    test('is saved after signing up', () async {
      final preferences = await createTestPreferences();
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(latency: Duration.zero),
          ),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
      )..listen(signUpFormProvider, (_, _) {});

      await container
          .read(signUpFormProvider.notifier)
          .signUp(
            const SignUpDetails(
              name: 'Ana',
              email: 'ana@example.com',
              password: 'password1',
              keepSignedIn: false,
              marketingOptIn: false,
            ),
          );

      expect(preferences.getBool(PreferenceKeys.keepSignedIn), isFalse);
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
