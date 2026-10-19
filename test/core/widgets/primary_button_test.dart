import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('shows its label and reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        PrimaryButton(label: 'Get Started', onPressed: () => taps++),
      );

      await tester.tap(find.text('Get Started'));

      expect(taps, 1);
    });

    testWidgets('matches the Figma size: full width, 60 tall', (tester) async {
      await tester.pumpApp(
        Center(
          child: PrimaryButton(label: 'Login', onPressed: () {}),
        ),
      );

      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, 60);
      expect(
        size.width,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
    });

    testWidgets('while loading, shows a spinner and ignores taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        PrimaryButton(label: 'Login', onPressed: () => taps++, isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
    });
  });
}
