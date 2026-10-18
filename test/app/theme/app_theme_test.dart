import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/theme/app_colors.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/app/theme/app_theme.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTextStyles', () {
    test('display styles convert Klasik sizes to Fredoka (× 0.83)', () {
      expect(AppTextStyles.headline.fontFamily, AppFonts.display);
      expect(AppTextStyles.headline.fontSize, closeTo(19.92, 0.001));
      // Line height stays at the Figma value: 32 px.
      const headline = AppTextStyles.headline;
      expect(headline.fontSize! * headline.height!, closeTo(32, 0.001));
      expect(headline.letterSpacing, closeTo(19.92 * 0.015, 0.001));
    });

    test('body styles use Manrope with −3 % letter spacing', () {
      const button = AppTextStyles.button;
      expect(button.fontFamily, AppFonts.body);
      expect(button.fontWeight, FontWeight.w700);
      expect(button.letterSpacing, closeTo(-0.48, 0.001));
    });
  });

  group('AppColors', () {
    test('match the Figma palette', () {
      expect(AppColors.light.primary, const Color(0xFFFDA758));
      expect(AppColors.light.textPrimary, const Color(0xFF573353));
      expect(AppColors.light.background, const Color(0xFFFFF3E9));
    });

    test('lerp blends every token', () {
      final black = AppColors.light.copyWith(primary: const Color(0xFF000000));
      final white = AppColors.light.copyWith(primary: const Color(0xFFFFFFFF));

      final mid = black.lerp(white, 0.5).primary;

      expect(mid.r, closeTo(0.5, 0.01));
      expect(identical(black.lerp(null, 0.5), black), isTrue);
    });
  });

  group('AppTheme', () {
    testWidgets('exposes the color tokens through context.colors', (
      tester,
    ) async {
      late AppColors colors;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox();
          },
        ),
      );

      expect(colors, AppColors.light);
      expect(AppTheme.light.scaffoldBackgroundColor, colors.background);
    });
  });
}
