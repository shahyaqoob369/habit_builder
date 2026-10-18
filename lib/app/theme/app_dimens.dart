import 'package:flutter/painting.dart';

/// Spacing scale, in logical pixels (Figma points).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal padding of every screen in the design.
  static const double screen = xl;
}

/// Corner radii from the design.
abstract final class AppRadii {
  /// Primary buttons (374×60).
  static const button = BorderRadius.all(Radius.circular(8));

  /// Cards, fields and habit cells: the default radius.
  static const card = BorderRadius.all(Radius.circular(12));

  /// Large cards and dialogs.
  static const large = BorderRadius.all(Radius.circular(20));

  /// Toggles and pills.
  static const pill = BorderRadius.all(Radius.circular(25));

  /// Bottom sheets: rounded top corners only.
  static const sheet = BorderRadius.vertical(top: Radius.circular(12));
}

/// Shadows from the design.
abstract final class AppShadows {
  /// Toggles and small controls.
  static const small = [
    BoxShadow(
      color: Color(0x80573353),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  /// Floating cards.
  static const card = [
    BoxShadow(
      color: Color(0x26573353),
      offset: Offset(0, 20),
      blurRadius: 60,
    ),
  ];

  /// Orange toggle knobs.
  static const primary = [
    BoxShadow(
      color: Color(0x80FDA758),
      offset: Offset(2, 3),
      blurRadius: 6,
    ),
  ];

  /// Glow under the center FAB (`AppPalette.orangeShadow` at 50 %).
  static const fab = [
    BoxShadow(
      color: Color(0x80D07E32),
      offset: Offset(0, 20),
      blurRadius: 60,
    ),
  ];
}
