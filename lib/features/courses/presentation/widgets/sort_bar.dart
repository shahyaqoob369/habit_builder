import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/chevron.dart';

/// "Sort By: [Popular ⌄]  [Filters ⌄]" (Figma "Filter").
class SortBar extends StatelessWidget {
  const SortBar({
    required this.label,
    required this.sortLabel,
    required this.filtersLabel,
    required this.onSortTap,
    required this.onFiltersTap,
    super.key,
  });

  final String label;
  final String sortLabel;
  final String filtersLabel;
  final VoidCallback onSortTap;
  final VoidCallback onFiltersTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(width: 4),
        Expanded(
          child: _DropdownBox(
            label: sortLabel,
            color: colors.textPrimary,
            onTap: onSortTap,
          ),
        ),
        const SizedBox(width: 21),
        SizedBox(
          width: 110,
          child: _DropdownBox(
            label: filtersLabel,
            color: colors.primaryDark,
            onTap: onFiltersTap,
          ),
        ),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: colors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: SizedBox(
          height: 33,
          child: Padding(
            padding: const EdgeInsets.only(left: 19, right: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ),
                Chevron(color: color, direction: AxisDirection.down),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
