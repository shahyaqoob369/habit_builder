import 'package:flutter/material.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// Fill of a [PrimaryButton] (Figma "Button" variants).
enum ButtonTone {
  /// Orange: the main action (Variant4).
  primary,

  /// White, for a second action on the cream background (Variant2).
  surface,

  /// Cream, for a second action on a white card (Variant3).
  soft,
}

/// The full-width call-to-action button (Figma "Button 374x"): 60 tall,
/// radius 8, plum bold label. Styling comes from the theme's
/// `filledButtonTheme`; [tone] swaps the fill.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.tone = ButtonTone.primary,
    super.key,
  });

  final ButtonTone tone;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Shows a spinner instead of the label and ignores taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: switch (tone) {
          ButtonTone.primary => null,
          ButtonTone.surface => FilledButton.styleFrom(
            backgroundColor: context.colors.surface,
          ),
          ButtonTone.soft => FilledButton.styleFrom(
            backgroundColor: context.colors.background,
          ),
        },
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.colors.textPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
