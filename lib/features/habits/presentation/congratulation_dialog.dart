import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// What the user chose in the congratulation popup.
enum CongratulationChoice { createHabit, continueOn }

/// Congratulation popup (Figma "Congratulation Popup"): a white card at the
/// bottom of the screen with the teepee, the title, a line of text and two
/// buttons. Shown when a streak milestone is reached.
Future<CongratulationChoice?> showCongratulation(
  BuildContext context, {
  required String habitName,
  required int streak,
}) {
  return showGeneralDialog<CongratulationChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.colors.scrim,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, _) =>
        _CongratulationCard(habitName: habitName, streak: streak),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    ),
  );
}

class _CongratulationCard extends StatelessWidget {
  const _CongratulationCard({required this.habitName, required this.streak});

  final String habitName;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.screen,
          AppSpacing.screen,
          // Figma: 20 pt above the bottom edge (inside the home indicator).
          bottom > 20 ? bottom - 14 : AppSpacing.screen,
        ),
        child: Material(
          color: colors.surface,
          borderRadius: AppRadii.large,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 312),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          HabitImages.teepee,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    Transform.translate(
                      // Figma: the title overlaps the illustration's foot.
                      offset: const Offset(0, -26),
                      child: Column(
                        children: [
                          Text(
                            l10n.congratulationTitle.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.congratulationBody(habitName, streak),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.optionLabel.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    PrimaryButton(
                      label: l10n.congratulationCreate,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(CongratulationChoice.createHabit),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: l10n.congratulationContinue,
                      tone: ButtonTone.soft,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(CongratulationChoice.continueOn),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Semantics(
                  button: true,
                  label: l10n.close,
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: () => Navigator.of(context).pop(),
                    radius: 24,
                    child: const AppIcon.original(AppIcons.close),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
