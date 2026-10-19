import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/highlighted_text.dart';
import 'package:habit_builder/features/onboarding/domain/onboarding_slide.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// One onboarding page: title, illustration and highlighted subtitle.
///
/// The illustration area flexes with the screen height; the illustration
/// keeps its exact Figma placement inside it and is scaled down (never up)
/// to fit.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({required this.slide, super.key});

  final OnboardingSlide slide;

  /// Title top in Figma (80) minus the 44 pt status bar of the frame.
  static const _titleTop = 36.0;

  /// Title and subtitle are 350 wide in the 414 frame.
  static const _textPadding = EdgeInsets.symmetric(horizontal: 32);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: _titleTop),
        Padding(
          padding: _textPadding,
          child: Text(
            slide.title(l10n).toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall,
          ),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox.fromSize(
              size: OnboardingSlide.illustrationArea,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fromRect(
                    rect: slide.imageRect,
                    child: Image.asset(slide.image, fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: _textPadding,
          child: HighlightedText(
            slide.subtitle(l10n),
            style: AppTextStyles.lead,
            highlightColor: context.colors.primaryDark,
            textAlign: TextAlign.center,
            uppercase: true,
          ),
        ),
      ],
    );
  }
}
