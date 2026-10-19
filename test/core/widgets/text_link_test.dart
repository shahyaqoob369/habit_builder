import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/text_link.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('TextLink', () {
    testWidgets('without a prompt, underlines the label', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Material(
          child: TextLink(label: 'Forgot Password?', onTap: () => taps++),
        ),
      );

      final text = tester.widget<Text>(find.text('Forgot Password?'));
      expect(text.style?.decoration, TextDecoration.underline);
      await tester.tap(find.byType(TextLink));
      expect(taps, 1);
    });

    testWidgets('with a prompt, shows it before the bold label', (
      tester,
    ) async {
      await tester.pumpApp(
        Material(
          child: TextLink(
            prompt: 'Don’t have an account?',
            label: 'Sign up',
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Don’t have an account? Sign up'), findsOneWidget);
    });
  });
}
