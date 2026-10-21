import 'package:flutter/painting.dart';

/// Raw colors from the Figma file and its Branding Guideline.
///
/// Widgets never use these directly; they read the semantic tokens in
/// `AppColors` through `context.colors`.
abstract final class AppPalette {
  // Brand palette (Branding Guideline).
  static const eclipse = Color(0xFF573353);
  static const sunset = Color(0xFFF65B4E);
  static const twilight = Color(0xFF29319F);
  static const morning = Color(0xFFFFBA7C);
  static const fog = Color(0xFFFFDEEF);

  // Colors measured in the screens.
  static const orange = Color(0xFFFDA758);
  static const orangeDark = Color(0xFFFC9D45);
  static const orangeLight = Color(0xFFF9B566);
  static const orangeShadow = Color(0xFFD07E32);
  static const magenta = Color(0xFF973456);
  static const cream = Color(0xFFFFF3E9);
  static const linen = Color(0xFFFFF6ED);
  static const sand = Color(0xFFFBEADB);
  static const white = Color(0xFFFFFFFF);
  static const lilacGrey = Color(0xFFC8C1C8);
  static const midnight = Color(0xFF040920);
}
