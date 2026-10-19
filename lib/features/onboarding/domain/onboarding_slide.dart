import 'package:flutter/painting.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The four onboarding pages (Figma "Introduction 1–4").
enum OnboardingSlide {
  welcome(AppImages.onboardingIntro1, Rect.fromLTWH(50, 0, 324, 492)),
  createHabit(AppImages.onboardingIntro2, Rect.fromLTWH(8, 42, 399, 399)),
  trackProgress(AppImages.onboardingIntro3, Rect.fromLTWH(0, 52, 414, 408)),
  community(AppImages.onboardingIntro4, Rect.fromLTWH(-2, 103, 417, 309))
  ;

  const OnboardingSlide(this.image, this.imageRect);

  /// Size of the design's illustration area: between the title (ends at
  /// y 144) and the subtitle (starts at y 651) of the 414-wide frame.
  static const illustrationArea = Size(414, 507);

  final String image;

  /// Where the illustration sits inside [illustrationArea], as in Figma.
  final Rect imageRect;

  String title(AppLocalizations l10n) => switch (this) {
    welcome => l10n.onboardingWelcomeTitle,
    createHabit => l10n.onboardingCreateHabitTitle,
    trackProgress => l10n.onboardingTrackProgressTitle,
    community => l10n.onboardingCommunityTitle,
  };

  /// Contains `<h>` markers for the highlighted words.
  String subtitle(AppLocalizations l10n) => switch (this) {
    welcome => l10n.onboardingWelcomeSubtitle,
    createHabit => l10n.onboardingCreateHabitSubtitle,
    trackProgress => l10n.onboardingTrackProgressSubtitle,
    community => l10n.onboardingCommunitySubtitle,
  };
}
