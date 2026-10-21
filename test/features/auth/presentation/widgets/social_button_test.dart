import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/presentation/widgets/social_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('SocialButton', () {
    testWidgets('is 50 pt tall and reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: SocialButton(
            provider: SocialProvider.google,
            label: 'Google',
            onPressed: () => taps++,
          ),
        ),
      );

      expect(tester.getSize(find.byType(SocialButton)).height, 50);
      await tester.tap(find.text('Google'));
      expect(taps, 1);
    });

    testWidgets('the wide form puts the label 115 pt in', (tester) async {
      await tester.pumpApp(
        Center(
          child: SocialButton(
            provider: SocialProvider.apple,
            label: 'Continue with Apple',
            wide: true,
            onPressed: () {},
          ),
        ),
      );

      final button = tester.getRect(find.byType(SocialButton));
      final label = tester.getRect(find.text('Continue with Apple'));
      expect(label.left - button.left, 115);
    });

    testWidgets('while loading, shows a spinner and ignores taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: SocialButton(
            provider: SocialProvider.google,
            label: 'Google',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Google'));
      expect(taps, 0);
    });
  });
}
