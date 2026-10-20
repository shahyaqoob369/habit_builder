import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_toggle.dart';

/// A reminder time (Figma "Time Set"): 92 pt tall; on: cream with orange
/// text, off: gray with plum text; an On/Off toggle below the time. The
/// whole tile toggles it.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    required this.label,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  static const height = 92.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      toggled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!enabled),
      child: Material(
        color: enabled ? colors.background : colors.disabled,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: () => onChanged(!enabled),
          borderRadius: AppRadii.card,
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                const SizedBox(height: 15),
                FittedBox(
                  child: Text(
                    label,
                    style: AppTextStyles.timeTile.copyWith(
                      color: enabled ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppToggle(value: enabled, onChanged: null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
