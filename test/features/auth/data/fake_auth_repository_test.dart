import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';

void main() {
  group('FakeAuthRepository', () {
    late FakeAuthRepository auth;

    setUp(() => auth = FakeAuthRepository(latency: Duration.zero));

    Matcher failsWith(AuthFailure failure) => throwsA(
      isA<AuthException>().having((e) => e.failure, 'failure', failure),
    );

    SignUpDetails details(String email) => SignUpDetails(
      name: ' Mira ',
      email: email,
      password: 'secret123',
      keepSignedIn: true,
      marketingOptIn: false,
    );

    test('signs in the demo account, ignoring email case and spaces', () async {
      final user = await auth.signInWithEmail(
        email: ' DEMO@example.com ',
        password: FakeAuthRepository.demoPassword,
      );

      expect(user.email, FakeAuthRepository.demoEmail);
      expect(auth.currentUser, user);
    });

    test('rejects a wrong password or an unknown email alike', () {
      expect(
        auth.signInWithEmail(
          email: FakeAuthRepository.demoEmail,
          password: 'x',
        ),
        failsWith(AuthFailure.invalidCredentials),
      );
      expect(
        auth.signInWithEmail(email: 'nobody@example.com', password: 'x'),
        failsWith(AuthFailure.invalidCredentials),
      );
    });

    test('signs up a new account, which can then log in', () async {
      final user = await auth.signUp(details('mira@example.com'));
      expect(user.name, 'Mira');

      await auth.signOut();
      expect(auth.currentUser, isNull);

      await auth.signInWithEmail(
        email: 'mira@example.com',
        password: 'secret123',
      );
      expect(auth.currentUser?.email, 'mira@example.com');
    });

    test('refuses to sign up an email that already has an account', () {
      expect(
        auth.signUp(details(FakeAuthRepository.demoEmail)),
        failsWith(AuthFailure.emailAlreadyInUse),
      );
    });

    test('accepts any email for a password reset', () async {
      await expectLater(
        auth.sendPasswordResetEmail('nobody@example.com'),
        completes,
      );
    });

    test('social sign-in signs a sample user in', () async {
      expect((await auth.signInWithGoogle()).email, contains('google'));
      expect((await auth.signInWithFacebook()).email, contains('facebook'));
    });
  });
}
