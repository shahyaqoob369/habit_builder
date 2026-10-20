import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppHeader', () {
    testWidgets('centers the title between its buttons, below the status '
        'bar', (tester) async {
      tester
        ..useScreen(designSize)
        ..view.padding = const FakeViewPadding(top: 44 * 3);
      await tester.pumpApp(
        Scaffold(
          body: AppHeader(
            title: 'Homepage',
            leading: HeaderIconButton(
              icon: AppIcons.menu,
              tooltip: 'Menu',
              onPressed: () {},
            ),
          ),
        ),
      );

      final title = tester.getRect(find.text('Homepage'));
      expect(title.center.dx, 207);
      // Figma: title box at y 45, 32 tall; circles at y 39 (here 44).
      expect(title.center.dy, closeTo(44 + 22, 0.5));
      expect(find.bySemanticsLabel('Homepage'), findsOneWidget);
    });
  });
}
