import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// A day in the Home week strip (Figma "Day"): 50 pt white square with the
/// weekday and date; today has a short plum bar along the top.
class DayChip extends StatelessWidget {
  const DayChip({
    required this.weekday,
    required this.date,
    required this.isToday,
    super.key,
  });

  /// Short weekday, shown uppercase ("SUN").
  final String weekday;
  final int date;
  final bool isToday;

  static const size = 50.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isToday)
            Positioned(
              top: 0,
              child: Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  boxShadow: AppShadows.small,
                ),
              ),
            ),
          // The chip has a fixed size: very large text sizes shrink to fit.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekday.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                Text('$date', style: AppTextStyles.dateNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
