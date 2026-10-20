import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Asks how easy today's habit felt, 1–10. Returns null when skipped.
///
/// Not in the design: it feeds "Average Easiness Score" (owner question
/// Q2), built from the design's tiles and type.
Future<int?> showEasinessSheet(BuildContext context) {
  return showAppSheet<int>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      final colors = context.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.easinessTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.easinessBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.helper.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                childAspectRatio: 1.2,
                children: [
                  for (var score = 1; score <= 10; score++)
                    Material(
                      color: colors.background,
                      borderRadius: AppRadii.card,
                      child: InkWell(
                        borderRadius: AppRadii.card,
                        onTap: () => Navigator.of(context).pop(score),
                        child: Center(
                          child: Text('$score', style: AppTextStyles.timeTile),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textMuted,
                  textStyle: AppTextStyles.button,
                ),
                child: Text(l10n.skip),
              ),
            ],
          ),
        ),
      );
    },
  );
}
