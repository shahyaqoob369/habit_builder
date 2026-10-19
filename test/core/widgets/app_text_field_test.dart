import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/theme/app_colors.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTextField', () {
    Future<void> pumpField(WidgetTester tester, AppTextField field) {
      return tester.pumpApp(
        Scaffold(
          body: Padding(padding: const EdgeInsets.all(20), child: field),
        ),
      );
    }

    Color? iconColor(WidgetTester tester) {
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      return svg.colorFilter ==
              ColorFilter.mode(
                AppColors.light.primary,
                BlendMode.srcIn,
              )
          ? AppColors.light.primary
          : AppColors.light.textMuted;
    }

    testWidgets('matches the Figma geometry: 56 tall, text 65 pt in', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(hintText: 'Email', icon: AppIcons.mail),
      );

      final field = tester.getRect(find.byType(AppTextField));
      final text = tester.getRect(find.byType(EditableText));
      expect(field.height, 56);
      expect(text.left - field.left, 65);
    });

    testWidgets('without an icon the text starts 20 pt in', (tester) async {
      await pumpField(tester, const AppTextField(hintText: 'Email'));

      final field = tester.getRect(find.byType(AppTextField));
      final text = tester.getRect(find.byType(EditableText));
      expect(text.left - field.left, 20);
    });

    testWidgets('the icon turns orange once the field is focused or filled', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(hintText: 'Email', icon: AppIcons.mail),
      );
      expect(iconColor(tester), AppColors.light.textMuted);

      await tester.enterText(find.byType(TextField), 'mira@example.com');
      await tester.pump();
      expect(iconColor(tester), AppColors.light.primary);
    });

    testWidgets('a password field toggles between hidden and shown', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(hintText: 'Password', obscurable: true),
      );
      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;

      expect(obscured(), isTrue);
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.text('Hide'), findsOneWidget);
    });

    testWidgets('shows the validator message below the field', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpApp(
        Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              hintText: 'Email',
              validator: (value) => 'Please enter your email',
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
