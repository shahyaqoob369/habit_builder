// Runs against the real Firebase project, on a simulator or device:
//   flutter test integration_test/auth_flow_test.dart -d <device id>
// It creates a throwaway account and deletes it again at the end.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

Matcher _fails(AuthFailure failure) => throwsA(
  isA<AuthException>().having((e) => e.failure, 'failure', failure),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(
    () => Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  );

  testWidgets('an email account from sign up to deletion', (tester) async {
    final repository = FirebaseAuthRepository();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'integration-$stamp@example.com';
    const password = 'Integration-test-1';
    await repository.signOut();

    // Sign up creates the account and its profile.
    final user = await repository.signUp(
      SignUpDetails(
        name: 'Integration',
        email: email,
        password: password,
        keepSignedIn: true,
        marketingOptIn: true,
      ),
    );
    expect(user.name, 'Integration');
    expect(user.hasPassword, isTrue);
    final profile = FirebaseFirestore.instance.doc('users/${user.id}');
    // The profile is saved in the background; wait until the server has it.
    await FirebaseFirestore.instance.waitForPendingWrites();
    final saved = (await profile.get()).data();
    expect(saved?['name'], 'Integration');
    expect(saved?['marketingOptIn'], isTrue);
    await expectLater(
      repository.signUp(
        SignUpDetails(
          name: 'Again',
          email: email,
          password: password,
          keepSignedIn: true,
          marketingOptIn: false,
        ),
      ),
      _fails(AuthFailure.emailAlreadyInUse),
    );

    // Sign out, then back in.
    await repository.signOut();
    expect(repository.currentUser, isNull);
    await expectLater(
      repository.signInWithEmail(email: email, password: 'wrong-password'),
      _fails(AuthFailure.invalidCredentials),
    );
    final again = await repository.signInWithEmail(
      email: email,
      password: password,
    );
    expect(again.id, user.id);

    // Rename.
    final renamed = await repository.updateName('Renamed');
    expect(renamed.name, 'Renamed');
    await FirebaseFirestore.instance.waitForPendingWrites();
    expect((await profile.get()).data()?['name'], 'Renamed');

    // Reset emails don't reveal whether an account exists.
    await repository.sendPasswordResetEmail('nobody-$stamp@example.com');

    // Deleting needs the right password, then removes everything.
    await expectLater(
      repository.deleteAccount(password: 'wrong-password'),
      _fails(AuthFailure.invalidCredentials),
    );
    await repository.deleteAccount(password: password);
    expect(repository.currentUser, isNull);
    await expectLater(
      repository.signInWithEmail(email: email, password: password),
      _fails(AuthFailure.invalidCredentials),
    );
  });

  testWidgets('security rules keep other users out', (tester) async {
    final repository = FirebaseAuthRepository();
    await repository.signOut();
    // Signed out: no profile can be read.
    await expectLater(
      FirebaseFirestore.instance.doc('users/someone-else').get(),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );
  });
}
