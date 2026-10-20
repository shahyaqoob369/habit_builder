import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/application/habit_editor_controller.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

void main() {
  group('HabitEditorController', () {
    final today = DateTime(2026, 10, 20);
    late FakeHabitRepository repository;
    late ProviderContainer container;

    setUp(() async {
      repository = FakeHabitRepository(today: today);
      container =
          ProviderContainer.test(
              overrides: [
                habitRepositoryProvider.overrideWithValue(repository),
                todayProvider.overrideWithValue(today),
              ],
            )
            ..listen(habitEditorProvider, (_, _) {})
            // Riverpod pauses providers nobody listens to.
            ..listen(habitsProvider, (_, _) {});
      // Load the habits so a new one can pick the next color.
      await container.read(habitsProvider.future);
    });

    HabitEditorController editor() =>
        container.read(habitEditorProvider.notifier);
    HabitDraft draft() => container.read(habitEditorProvider);

    test('a new habit takes the next color in turn', () {
      editor().start(null);

      expect(draft().isEditing, isFalse);
      // Four sample habits already: back to the first color.
      expect(draft().color, HabitColor.orange);
      expect(draft().reminders, const [ReminderTime(10, 0)]);
    });

    test('will not save without a name, and says so', () async {
      editor()
        ..start(null)
        ..setName('   ');

      expect(await editor().save(), isFalse);
      expect(draft().showNameError, isTrue);

      editor().setName('Stretch');
      expect(draft().showNameError, isFalse);
    });

    test('keeps at least one day of the week', () {
      editor()
        ..start(null)
        ..setWeekdays({DateTime.monday})
        ..toggleWeekday(DateTime.monday);

      expect(draft().weekdays, {DateTime.monday});

      editor().toggleWeekday(DateTime.friday);
      expect(draft().weekdays, {DateTime.monday, DateTime.friday});
    });

    test('keeps reminders sorted and toggles them', () {
      editor()
        ..start(null)
        ..addReminder(const ReminderTime(7, 30))
        ..toggleReminder(const ReminderTime(6, 0));

      expect(draft().reminders, const [
        ReminderTime(6, 0),
        ReminderTime(7, 30),
        ReminderTime(10, 0),
      ]);

      editor().toggleReminder(const ReminderTime(10, 0));
      expect(draft().reminders, const [
        ReminderTime(6, 0),
        ReminderTime(7, 30),
      ]);
    });

    test('saves a new habit', () async {
      editor()
        ..start(null)
        ..setName(' Stretch ')
        ..setIcon(HabitIcon.relax)
        ..setNotifications(enabled: true);

      expect(await editor().save(), isTrue);

      final habits = await repository.watchHabits().first;
      final added = habits.last;
      expect(added.name, 'Stretch');
      expect(added.icon, HabitIcon.relax);
      expect(added.notificationsEnabled, isTrue);
      expect(added.createdAt, today);
    });

    test('edits and deletes an existing habit', () async {
      final read = (await repository.watchHabits().first).first;
      editor()
        ..start(read)
        ..setName('Read 20 pages');

      expect(draft().isEditing, isTrue);
      expect(await editor().save(), isTrue);
      var habits = await repository.watchHabits().first;
      expect(habits.first.name, 'Read 20 pages');
      expect(habits.first.log, read.log, reason: 'history is kept');

      await editor().delete();
      habits = await repository.watchHabits().first;
      expect(habits.any((h) => h.id == read.id), isFalse);
    });
  });
}
