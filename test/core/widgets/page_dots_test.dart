import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/page_dots.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('PageDots', () {
    testWidgets('draws one dot per page and exposes a semantics label', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(
          child: PageDots(count: 4, index: 1, semanticsLabel: 'Page 2 of 4'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Page 2 of 4'), findsOneWidget);
      // Each dot is a ring with a dot inside.
      expect(find.byType(AnimatedContainer), findsNWidgets(8));
    });

    testWidgets('matches the Figma width: 17 + 3 × 11 + 3 × 7 gaps', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(
          child: PageDots(count: 4, index: 0, semanticsLabel: 'Page 1 of 4'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(Row)).width, 17 + 3 * 11 + 3 * 7);
    });
  });
}
