import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/app/theme/app_colors.dart';
import 'package:habit_builder/app/theme/app_palette.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';

/// Builds the app's [ThemeData] from the design tokens.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light);

  static ThemeData _build(AppColors colors) {
    final scheme = ColorScheme.light(
      primary: colors.primary,
      onPrimary: colors.textPrimary,
      secondary: colors.primaryDark,
      onSecondary: colors.textPrimary,
      error: AppPalette.sunset,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      outline: colors.divider,
      scrim: colors.scrim,
    );

    const textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineMedium: AppTextStyles.headline,
      headlineSmall: AppTextStyles.quote,
      titleLarge: AppTextStyles.title,
      titleMedium: AppTextStyles.cardTitle,
      titleSmall: AppTextStyles.labelStrong,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.helper,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.labelStrong,
      labelSmall: AppTextStyles.overline,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppFonts.body,
      textTheme: textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.primarySoft,
        selectionHandleColor: colors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: colors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      extensions: [colors],
    );
  }
}
