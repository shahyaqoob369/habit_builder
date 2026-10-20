import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/features/habits/presentation/widgets/frequency_card.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Quick frequency choices (not in the design). Returns the chosen preset;
/// "Custom" is setting the days one by one on the card.
Future<FrequencyPreset?> showFrequencySheet(BuildContext context) {
  return showAppSheet<FrequencyPreset>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xs,
            children: [
              Text(l10n.newHabitFrequency, style: AppTextStyles.title),
              for (final preset in FrequencyPreset.values)
                ListTile(
                  title: Text(preset.label(l10n), style: AppTextStyles.body),
                  tileColor: context.colors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.card,
                  ),
                  onTap: () => Navigator.of(context).pop(preset),
                ),
              Text(
                l10n.frequencyCustomHint,
                style: AppTextStyles.helper.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
