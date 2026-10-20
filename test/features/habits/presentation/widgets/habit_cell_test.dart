import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_cell.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HabitCell', () {
    testWidgets('is the Large size by default and can scale', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            HabitCell(color: Colors.orange, status: DayStatus.done),
            HabitCell(color: Colors.orange, status: DayStatus.missed, size: 38),
          ],
        ),
      );

      final sizes = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(HabitCell),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((p) => p.size)
          .toList();
      expect(sizes, [const Size.square(54), const Size.square(38)]);
    });

    testWidgets('draws nothing for an unmarked day when asked', (
      tester,
    ) async {
      await tester.pumpApp(
        const HabitCell(color: Colors.orange, status: null, showEmpty: false),
      );

      expect(
        find.descendant(
          of: find.byType(HabitCell),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });
  });
}
