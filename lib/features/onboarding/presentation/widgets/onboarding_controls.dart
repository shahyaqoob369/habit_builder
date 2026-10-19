import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/widgets/page_dots.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Bottom controls: Skip · dots · Next, replaced by "Get Started" on the
/// last page.
class OnboardingControls extends StatelessWidget {
  const OnboardingControls({
    required this.pageCount,
    required this.pageIndex,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
    super.key,
  });

  /// Height of the primary button; the Skip/Next row is centered in the
  /// same space so the page above doesn't move.
  static const height = 60.0;

  final int pageCount;
  final int pageIndex;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  bool get _isLastPage => pageIndex == pageCount - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isLastPage
            ? Padding(
                key: const ValueKey('get-started'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: PrimaryButton(
                  label: l10n.onboardingGetStarted,
                  onPressed: onGetStarted,
                ),
              )
            : Padding(
                key: const ValueKey('pager'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: Row(
                  children: [
                    _TextAction(label: l10n.onboardingSkip, onTap: onSkip),
                    const Spacer(),
                    PageDots(
                      count: pageCount,
                      index: pageIndex,
                      semanticsLabel: l10n.onboardingPageIndicator(
                        pageIndex + 1,
                        pageCount,
                      ),
                    ),
                    const Spacer(),
                    _TextAction(label: l10n.onboardingNext, onTap: onNext),
                  ],
                ),
              ),
      ),
    );
  }
}

/// "Skip" / "Next": bold text with a 48 pt touch target. The 12 pt padding
/// puts the text 32 pt from the screen edge, as in Figma.
class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(label, style: AppTextStyles.lead),
        ),
      ),
    );
  }
}
