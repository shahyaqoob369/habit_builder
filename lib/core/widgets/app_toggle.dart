import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// On/Off switch from the design (Figma "Toggle OnOff"): a 54 × 30 pill.
/// Off: plum at 10 % with the plum knob on the left and "Off"; On: orange at
/// 20 % with the orange knob on the right and "On".
class AppToggle extends StatelessWidget {
  const AppToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;

  /// Null makes the toggle read-only (its parent handles taps).
  final ValueChanged<bool>? onChanged;

  /// What the toggle controls, for screen readers.
  final String? semanticLabel;

  static const width = 54.0;
  static const height = 30.0;
  static const _knob = 22.0;
  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final accent = value ? colors.primary : colors.textPrimary;
    final onChanged = this.onChanged;
    final toggle = AnimatedContainer(
      duration: _duration,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: value ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            // Figma: "On" 8 pt in from the left, "Off" 32 pt in.
            alignment: value
                ? const Alignment(-0.6, 0)
                : const Alignment(0.64, 0),
            child: Text(
              value ? l10n.toggleOn : l10n.toggleOff,
              style: AppTextStyles.overline.copyWith(color: accent),
            ),
          ),
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: _duration,
                width: _knob,
                height: _knob,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.5),
                      offset: Offset(value ? 2 : -2, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      toggled: value,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: onChanged == null
          ? toggle
          : GestureDetector(
              onTap: () => onChanged(!value),
              child: toggle,
            ),
    );
  }
}
