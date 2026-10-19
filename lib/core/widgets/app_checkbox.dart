import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';

/// Checkbox with its label (Figma "Text and Checkbox"): a 20 pt orange box
/// with a plum check, 11 pt before the label. The whole row toggles it.
///
/// The design only shows the checked state; unchecked is a white box with
/// an orange outline.
///
/// The row reaches [padding] beyond the box and label (17 pt before the box,
/// as in the design, and 9 pt above and below for a 40 pt touch target).
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  static const padding = EdgeInsetsDirectional.fromSTEB(17, 9, 8, 9);

  final bool value;

  /// Null disables the checkbox.
  final ValueChanged<bool>? onChanged;

  final String label;

  static const _duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        borderRadius: AppRadii.card,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // A label that wraps keeps the box beside its first line.
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 11,
            children: [
              AnimatedContainer(
                duration: _duration,
                width: 20,
                height: 20,
                // Centers the box on the label's 22 pt first line.
                margin: const EdgeInsets.only(top: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value ? colors.primary : colors.surface,
                  borderRadius: AppRadii.checkbox,
                  border: Border.all(color: colors.primary, width: 1.5),
                ),
                child: AnimatedOpacity(
                  duration: _duration,
                  opacity: value ? 1 : 0,
                  child: AppIcon(AppIcons.check, color: colors.textPrimary),
                ),
              ),
              Flexible(
                child: Text(label, style: AppTextStyles.optionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
