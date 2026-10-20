import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/chevron.dart';

/// A white 50 pt row with a label on the left and [trailing] on the right
/// (Figma "Reminder", "Notification").
class FormRow extends StatelessWidget {
  const FormRow({
    required this.label,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppTextStyles.body)),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Orange bold value with a chevron, as in "10:00AM ›" and "Custom ›".
class ValueChevron extends StatelessWidget {
  const ValueChevron({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Text(
          value,
          style: AppTextStyles.button.copyWith(color: colors.primary),
        ),
        Chevron(color: colors.primary),
      ],
    );
  }
}
