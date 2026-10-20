import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/app_toggle.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppToggle', () {
    testWidgets('is 54 × 30, says On or Off, and toggles', (tester) async {
      bool? changedTo;
      await tester.pumpApp(
        Center(
          child: AppToggle(value: false, onChanged: (v) => changedTo = v),
        ),
      );

      expect(tester.getSize(find.byType(AppToggle)), const Size(54, 30));
      expect(find.text('Off'), findsOneWidget);
      await tester.tap(find.byType(AppToggle));
      expect(changedTo, isTrue);
    });

    testWidgets('read-only without onChanged', (tester) async {
      await tester.pumpApp(
        const Center(child: AppToggle(value: true, onChanged: null)),
      );

      expect(find.text('On'), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}
