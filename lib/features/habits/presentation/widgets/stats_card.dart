import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The four numbers of a habit (Figma "Analytics"): a white card split in
/// a 2 × 2 grid, each cell a big value, a caption and a round icon.
class StatsCard extends StatelessWidget {
  const StatsCard({required this.stats, super.key});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final easiness = stats.averageEasiness;
    final divider = VerticalDivider(width: 1, color: colors.divider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _Stat(
                  value: l10n.statDays(stats.longestStreak),
                  label: l10n.statLongestStreak,
                  icon: AppIcons.statStreak,
                ),
                divider,
                _Stat(
                  value: l10n.statDays(stats.currentStreak),
                  label: l10n.statCurrentStreak,
                  icon: AppIcons.statLightning,
                ),
              ],
            ),
          ),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                _Stat(
                  value: l10n.statPercent((stats.completionRate * 100).round()),
                  label: l10n.statCompletionRate,
                  icon: AppIcons.statCompletion,
                ),
                divider,
                _Stat(
                  value: easiness == null
                      ? '–'
                      : easiness.toStringAsFixed(
                          easiness == easiness.roundToDouble() ? 0 : 1,
                        ),
                  label: l10n.statAverageEasiness,
                  icon: AppIcons.statEasiness,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(19, 27, 19, 19),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value.toUpperCase(), style: AppTextStyles.stat),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon.original(icon),
            ],
          ),
        ),
      ),
    );
  }
}
