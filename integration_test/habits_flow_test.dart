// Runs against the real Firebase project, on a simulator or device:
//   flutter test integration_test/habits_flow_test.dart -d <device id>
// It creates a throwaway account with habits and deletes it at the end.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/habits/data/firestore_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/settings/data/feedback_repositories.dart';
import 'package:habit_builder/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

Matcher get _denied => throwsA(
  isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied'),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(
    () => Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  );

  testWidgets('habits are saved per user and deleted with the account', (
    tester,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuthRepository();
    await auth.signOut();
    const password = 'Integration-test-1';
    final user = await auth.signUp(
      SignUpDetails(
        name: 'Habits',
        email:
            'integration-${DateTime.now().millisecondsSinceEpoch}'
            '@example.com',
        password: password,
        keepSignedIn: true,
        marketingOptIn: false,
      ),
    );
    final repository = FirestoreHabitRepository(uid: user.id);
    final today = DateTime(2026, 10, 20);

    Future<List<Habit>> saved(bool Function(List<Habit>) until) =>
        repository.watchHabits().firstWhere(until);

    // Add two habits; they come back in creation order.
    final read = await repository.addHabit(
      Habit(
        id: '',
        name: 'Read',
        color: HabitColor.blue,
        createdAt: today,
        weekdays: const {1, 3, 5},
        reminders: const [ReminderTime(7, 30)],
      ),
    );
    await repository.addHabit(
      Habit(
        id: '',
        name: 'Walk',
        color: HabitColor.red,
        createdAt: today,
      ),
    );
    var habits = await saved((h) => h.length == 2);
    expect(habits.map((h) => h.name), ['Read', 'Walk']);
    expect(habits.first.reminders, const [ReminderTime(7, 30)]);

    // Mark a day, rate it, then rename the habit.
    await repository.setStatus(read.id, today, DayStatus.done);
    habits = await saved((h) => h.first.statusOn(today) == DayStatus.done);
    await repository.updateHabit(
      habits.first.withEasiness(today, 7).copyWith(name: 'Read more'),
    );
    habits = await saved((h) => h.first.name == 'Read more');
    expect(habits.first.easiness[today], 7);

    // Unmarking the day clears it and its rating.
    await repository.setStatus(read.id, today, null);
    habits = await saved((h) => h.first.statusOn(today) == null);
    expect(habits.first.easiness, isEmpty);

    // Every write above reached the server (the rules accepted it).
    await firestore.waitForPendingWrites();

    // The rules reject bad habits and other users' data.
    final mine = firestore.collection('users/${user.id}/habits');
    await expectLater(mine.doc().set({'name': ''}), _denied);
    await expectLater(
      firestore.collection('users/someone-else/habits').get(),
      _denied,
    );

    // Deleting a habit.
    await repository.deleteHabit(read.id);
    habits = await saved((h) => h.length == 1);
    expect(habits.single.name, 'Walk');
    await firestore.waitForPendingWrites();

    // Feedback is saved under the user.
    await firestoreFeedback(uid: user.id)('Love it');
    await firestore.waitForPendingWrites();
    final feedback = firestore.collection('users/${user.id}/feedback');
    expect((await feedback.get()).docs.single.data()['message'], 'Love it');

    // Deleting the account deletes its habits and feedback too.
    await auth.deleteAccount(password: password);
    expect(auth.currentUser, isNull);
    final leftover = await mine.get(const GetOptions(source: Source.cache));
    expect(leftover.docs, isEmpty);
    final leftoverFeedback = await feedback.get(
      const GetOptions(source: Source.cache),
    );
    expect(leftoverFeedback.docs, isEmpty);
  });
}
