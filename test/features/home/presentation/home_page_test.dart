import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:habit_builder/features/home/presentation/widgets/quote_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('HomePage', () {
    final today = DateTime(2026, 10, 20); // a Tuesday
    late SharedPreferencesWithCache preferences;

    setUp(() async => preferences = await createTestPreferences());

    Future<void> pumpHome(
      WidgetTester tester, {
      FakeHabitRepository? repository,
      Stream<List<Habit>>? habits,
    }) async {
      tester
        ..useScreen(designSize)
        ..view.padding = const FakeViewPadding(top: 44 * 3);
      await tester.pumpApp(
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          todayProvider.overrideWithValue(today),
          habitRepositoryProvider.overrideWithValue(
            repository ?? FakeHabitRepository(today: today),
          ),
          if (habits != null) habitsProvider.overrideWith((ref) => habits),
        ],
      );
      await tester.pump();
    }

    String cell(String habit, String date, String status) =>
        '$habit, $date, $status';

    testWidgets('lays out the quote and the grid as in Figma', (tester) async {
      await pumpHome(tester);

      expect(tester.getTopLeft(find.byType(QuoteCard)), const Offset(20, 107));
      expect(tester.getCenter(find.text('HABITS')).dy, 272 + 25);
      expect(tester.getCenter(find.text('Read A Book')).dy, 335 + 35);
      expect(tester.getCenter(find.text('Walk Dog')).dy, 569 + 35);
      expect(
        find.text('WE FIRST MAKE OUR HABITS,\nAND THEN OUR HABITS\nMAKE US.'),
        findsOneWidget,
      );
    });

    testWidgets('the strip ends on today, marked with a bar', (tester) async {
      await pumpHome(tester);

      expect(find.text('20'), findsOneWidget);
      expect(find.text('TUE'), findsWidgets);
      expect(
        find.bySemanticsLabel(cell('Read A Book', 'Tue, Oct 20', 'done')),
        findsOneWidget,
      );
    });

    testWidgets('tapping a cell cycles done → missed → not marked', (
      tester,
    ) async {
      await pumpHome(tester);
      final label = cell('Exercise', 'Tue, Oct 20', 'not marked');

      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump();
      expect(
        find.bySemanticsLabel(cell('Exercise', 'Tue, Oct 20', 'done')),
        findsOneWidget,
      );

      await tester.tap(
        find.bySemanticsLabel(cell('Exercise', 'Tue, Oct 20', 'done')),
      );
      await tester.pump();
      expect(
        find.bySemanticsLabel(cell('Exercise', 'Tue, Oct 20', 'missed')),
        findsOneWidget,
      );
    });

    testWidgets('without habits, invites the user to add one', (tester) async {
      await pumpHome(tester, repository: FakeHabitRepository(seed: false));

      expect(find.text('NO HABITS YET'), findsOneWidget);
      expect(find.text('HABITS'), findsNothing);
    });

    testWidgets('shows a spinner while loading', (tester) async {
      await pumpHome(tester, habits: const Stream.empty());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows an error with a retry button', (tester) async {
      await pumpHome(tester, habits: Stream.error(Exception('offline')));

      expect(find.text('SOMETHING WENT WRONG'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('fits a small phone with large text', (tester) async {
      tester.useScreen(smallPhoneSize, textScale: 1.3);
      await tester.pumpApp(
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          todayProvider.overrideWithValue(today),
          habitRepositoryProvider.overrideWithValue(
            FakeHabitRepository(today: today),
          ),
        ],
      );
      await tester.pump();

      expect(find.text('Walk Dog'), findsOneWidget);
    });
  });
}
