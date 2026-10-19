import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/app_checkbox.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppCheckbox', () {
    testWidgets('tapping the label toggles the value', (tester) async {
      bool? changedTo;
      await tester.pumpApp(
        Material(
          child: AppCheckbox(
            label: 'Keep me signed in',
            value: false,
            onChanged: (value) => changedTo = value,
          ),
        ),
      );

      await tester.tap(find.text('Keep me signed in'));

      expect(changedTo, isTrue);
    });

    testWidgets('reports its checked state to screen readers', (tester) async {
      await tester.pumpApp(
        Material(
          child: AppCheckbox(
            label: 'Keep me signed in',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(AppCheckbox)),
        matchesSemantics(
          label: 'Keep me signed in',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });
  });
}
