import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/habit_icons.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Name field and icon button (Figma "Habit Name"): a 49 pt white field and,
/// 12 pt to its right, a 48 × 49 tile with the habit icon and an orange "+"
/// badge on its corner.
class HabitNameRow extends StatelessWidget {
  const HabitNameRow({
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
    required this.onIconTap,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final HabitIcon icon;
  final Color iconColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onIconTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        Expanded(
          child: AppTextField(
            controller: controller,
            hintText: l10n.newHabitNameHint,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            errorText: errorText,
            // 49 pt tall, text 20 pt in (Material adds 4).
            contentPadding: const EdgeInsetsDirectional.fromSTEB(
              16,
              16.5,
              16,
              16.5,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: l10n.newHabitIconTooltip,
          excludeSemantics: true,
          onTap: onIconTap,
          child: GestureDetector(
            onTap: onIconTap,
            child: SizedBox(
              width: 52,
              height: 53,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 48,
                      height: 49,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadii.card,
                      ),
                      child: FaIcon(icon.glyph, size: 32, color: iconColor),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: AppIcon.original(AppIcons.circlePlus),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
