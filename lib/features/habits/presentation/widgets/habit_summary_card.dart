import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';

/// Top card of the habit detail screen: the teepee in a tinted square, the
/// habit name, its frequency and its reminders.
class HabitSummaryCard extends StatelessWidget {
  const HabitSummaryCard({
    required this.name,
    required this.color,
    required this.repeat,
    required this.reminders,
    super.key,
  });

  final String name;
  final Color color;

  /// "Repeat every day".
  final String repeat;

  /// "Reminders: 10:00 AM".
  final String reminders;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final muted = AppTextStyles.caption.copyWith(color: colors.textMuted);
    return Container(
      // Figma: 100 pt tall with the 75 pt thumbnail 12 pt from the top.
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Row(
        spacing: AppSpacing.xl,
        children: [
          Container(
            width: 75,
            height: 75,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadii.card,
            ),
            child: Image.asset(
              HabitImages.teepee,
              width: 60,
              height: 63,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
                _Line(icon: AppIcons.repeat, text: repeat, style: muted),
                const SizedBox(height: 6),
                _Line(
                  icon: AppIcons.notification,
                  text: reminders,
                  style: muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, required this.style});

  final String icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 9,
      children: [
        SizedBox.square(
          dimension: 15,
          child: AppIcon(icon, color: context.colors.primaryDark),
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
