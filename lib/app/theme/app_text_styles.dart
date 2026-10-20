import 'package:flutter/painting.dart';

/// Font families bundled in pubspec.yaml.
abstract final class AppFonts {
  /// Body text.
  static const body = 'Manrope';

  /// Display headings: the free stand-in for the design's Klasik.
  static const display = 'Fredoka';
}

/// Converts a Klasik size from Figma to the matching Fredoka size.
///
/// Fredoka's cap height is 0.700 of its size and Klasik's is 0.583, so the
/// same cap height needs 0.83 × the size.
const double _klasikToFredoka = 0.83;

/// Fredoka runs slightly narrower than Klasik; this tracking (per point of
/// font size) brings line widths back to within 1 %.
const double _displayTracking = 0.015;

/// Every Manrope style in the design uses −3 % letter spacing.
const double _bodyTracking = -0.03;

/// Text styles from the Figma file, without color.
///
/// Text color comes from the theme (`textPrimary` by default); override it
/// with `copyWith(color: context.colors.…)`.
///
/// Line heights are the exact Figma values. Figma spreads the extra leading
/// evenly above and below the text, hence [TextLeadingDistribution.even].
abstract final class AppTextStyles {
  // Display — Fredoka (design: Klasik), always uppercase in the UI.

  /// Splash title. Klasik 40/40.
  static const displayLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 40 * _klasikToFredoka,
    height: 40 / (40 * _klasikToFredoka),
    letterSpacing: 40 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Banner heading ("HABIT COURSES"). Klasik 36/32.
  static const displayMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 36 * _klasikToFredoka,
    height: 32 / (36 * _klasikToFredoka),
    letterSpacing: 36 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Onboarding titles. Klasik 32/32.
  static const displaySmall = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 32 * _klasikToFredoka,
    height: 32 / (32 * _klasikToFredoka),
    letterSpacing: 32 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Page and card headings ("CREATE YOUR ACCOUNT"). Klasik 24/32.
  static const headline = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 24 * _klasikToFredoka,
    height: 32 / (24 * _klasikToFredoka),
    letterSpacing: 24 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Stat values ("20 DAYS", "98 %"). Klasik 24/16.
  static const stat = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 24 * _klasikToFredoka,
    height: 16 / (24 * _klasikToFredoka),
    letterSpacing: 24 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Home quote card. Klasik 18/20.5.
  static const quote = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 18 * _klasikToFredoka,
    height: 20.5 / (18 * _klasikToFredoka),
    letterSpacing: 18 * _klasikToFredoka * _displayTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Text — Manrope.

  /// Selected value in the time picker. 700 32/32.
  static const pickerSelected = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1,
    letterSpacing: 32 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Plan prices on the paywall. 700 24/14.
  static const price = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 14 / 24,
    letterSpacing: 24 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Other values in the time picker. 500 22/32.
  static const pickerOption = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 22,
    height: 32 / 22,
    letterSpacing: 22 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// The selected half of the am / pm switch. 700 22/24.
  static const periodSelected = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 24 / 22,
    letterSpacing: 22 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// The other half of the am / pm switch. 500 22/24.
  static const period = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 22,
    height: 24 / 22,
    letterSpacing: 22 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Reminder time tiles ("06:00 AM"). 700 20/16.
  static const timeTile = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 16 / 20,
    letterSpacing: 20 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Screen and sheet titles ("Homepage", "New Habit"). 700 18/32.
  static const title = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 32 / 18,
    letterSpacing: 18 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Course card titles. 700 18/25.
  static const cardTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 25 / 18,
    letterSpacing: 18 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Onboarding subtitle, Skip and Next. 700 17/24.
  static const lead = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 17,
    height: 24 / 17,
    letterSpacing: 17 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Card and calendar titles ("Read a Book", "January"). 700 16/32.
  static const subtitle = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 2,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Buttons, typed input text and row values. 700 16/16.
  static const button = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Panel headings ("Log in with email"). 500 16/24.
  static const sectionLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Checkbox labels ("Keep me signed in"). 500 16/22.
  static const optionLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 22 / 16,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Input placeholders, list rows. 500 16/16.
  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Emphasized 16 pt labels ("37 Lessons (2h 41m)"). 700 16/14.
  static const bodyStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 14 / 16,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Habit names in the Home grid, "HABITS". 700 14/20.
  static const rowLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Dates in the week strip ("18"). 700 16/13.
  static const dateNumber = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 13 / 16,
    letterSpacing: 16 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Habit names, calendar day numbers. 700 14/13.
  static const labelStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 13 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Small numeric labels (progress rings). 500 14/16.
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 16 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Helper text and text links ("Forgot Password?"). 500 14/22.
  static const helper = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 22 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Short tips under a heading ("Start this habit"). 500 14/18.
  static const note = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 18 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Multi-line paragraphs (community posts). 500 14/20.
  static const paragraph = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 14 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Meta text ("41m ago", "37 Lessons"). 500 12/14.
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 14 / 12,
    letterSpacing: 12 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Short bold labels ("Monthly", "Most Popular"). 700 12/13.
  static const captionStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 13 / 12,
    letterSpacing: 12 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Weekday labels (SUN, MON), toggle labels. 700 10/13.
  static const overline = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    height: 13 / 10,
    letterSpacing: 10 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Small dates ("06/14", "Today"). 500 10/13.
  static const micro = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    height: 13 / 10,
    letterSpacing: 10 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Like and comment counts. 500 8/10.9.
  static const tiny = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 8,
    height: 10.9 / 8,
    letterSpacing: 8 * _bodyTracking,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
