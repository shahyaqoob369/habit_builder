import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_palette.dart';

/// Semantic color tokens, provided through [ThemeData.extensions].
///
/// Read them with `context.colors`. Values come from the Figma screens; see
/// docs/DESIGN_SYSTEM.md for where each one is used.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primarySoft,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textMuted,
    required this.divider,
    required this.disabled,
    required this.scrim,
    required this.habitOrange,
    required this.habitRed,
    required this.habitBlue,
    required this.habitMagenta,
    required this.facebook,
  });

  static const light = AppColors(
    primary: AppPalette.orange,
    primaryDark: AppPalette.orangeDark,
    primaryLight: AppPalette.orangeLight,
    primarySoft: Color(0x33FDA758),
    background: AppPalette.cream,
    surface: AppPalette.white,
    textPrimary: AppPalette.eclipse,
    textMuted: Color(0x80573353),
    divider: AppPalette.cream,
    disabled: AppPalette.lilacGrey,
    scrim: Color(0x80040920),
    habitOrange: AppPalette.orangeDark,
    habitRed: AppPalette.sunset,
    habitBlue: AppPalette.twilight,
    habitMagenta: AppPalette.magenta,
    facebook: AppPalette.facebookBlue,
  );

  /// Primary buttons, links, checkboxes, typed input text.
  final Color primary;

  /// The orange habit color and the center FAB.
  final Color primaryDark;

  /// Inactive onboarding dots and soft accents.
  final Color primaryLight;

  /// 20 % primary: tinted fills such as the "On" toggle track.
  final Color primarySoft;

  /// Screen background.
  final Color background;

  /// Cards, fields and sheets.
  final Color surface;

  /// All text and icons.
  final Color textPrimary;

  /// Placeholders and secondary text (50 % of [textPrimary]).
  final Color textMuted;

  /// Hairlines inside cards and fields.
  final Color divider;

  /// Switched-off tiles and disabled controls.
  final Color disabled;

  /// Overlay behind bottom sheets and dialogs.
  final Color scrim;

  final Color habitOrange;
  final Color habitRed;
  final Color habitBlue;
  final Color habitMagenta;

  /// Facebook brand blue (social sign-in icon).
  final Color facebook;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primarySoft,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textMuted,
    Color? divider,
    Color? disabled,
    Color? scrim,
    Color? habitOrange,
    Color? habitRed,
    Color? habitBlue,
    Color? habitMagenta,
    Color? facebook,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      primarySoft: primarySoft ?? this.primarySoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      scrim: scrim ?? this.scrim,
      habitOrange: habitOrange ?? this.habitOrange,
      habitRed: habitRed ?? this.habitRed,
      habitBlue: habitBlue ?? this.habitBlue,
      habitMagenta: habitMagenta ?? this.habitMagenta,
      facebook: facebook ?? this.facebook,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      primaryDark: mix(primaryDark, other.primaryDark),
      primaryLight: mix(primaryLight, other.primaryLight),
      primarySoft: mix(primarySoft, other.primarySoft),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textMuted: mix(textMuted, other.textMuted),
      divider: mix(divider, other.divider),
      disabled: mix(disabled, other.disabled),
      scrim: mix(scrim, other.scrim),
      habitOrange: mix(habitOrange, other.habitOrange),
      habitRed: mix(habitRed, other.habitRed),
      habitBlue: mix(habitBlue, other.habitBlue),
      habitMagenta: mix(habitMagenta, other.habitMagenta),
      facebook: mix(facebook, other.facebook),
    );
  }
}
