import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';

void main() {
  group('FirebaseAuthRepository.failureFor', () {
    test('maps Firebase error codes to auth failures', () {
      const expected = {
        'invalid-credential': AuthFailure.invalidCredentials,
        'wrong-password': AuthFailure.invalidCredentials,
        'user-not-found': AuthFailure.invalidCredentials,
        'email-already-in-use': AuthFailure.emailAlreadyInUse,
        'network-request-failed': AuthFailure.network,
        'too-many-requests': AuthFailure.tooManyAttempts,
        'requires-recent-login': AuthFailure.requiresRecentLogin,
        'operation-not-allowed': AuthFailure.unavailable,
        'something-new': AuthFailure.unknown,
      };
      for (final MapEntry(:key, :value) in expected.entries) {
        expect(FirebaseAuthRepository.failureFor(key), value, reason: key);
      }
    });
  });
}
