import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('HeaderIconButton', () {
    testWidgets('is a 44 pt circle with a 48 pt touch target', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: HeaderIconButton(
            icon: AppIcons.back,
            tooltip: 'Back',
            onPressed: () => taps++,
          ),
        ),
      );

      expect(tester.getSize(find.byType(HeaderIconButton)), const Size(48, 48));
      final circle = find.descendant(
        of: find.byType(HeaderIconButton),
        matching: find.byType(Material),
      );
      expect(tester.getSize(circle), const Size(44, 44));
      await tester.tap(find.byTooltip('Back'));
      expect(taps, 1);
    });

    testWidgets('meets the tap target guideline', (tester) async {
      await tester.pumpApp(
        Center(
          child: HeaderIconButton(
            icon: AppIcons.help,
            tooltip: 'Help',
            onPressed: () {},
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
