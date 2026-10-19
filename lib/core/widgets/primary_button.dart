import 'package:flutter/material.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// The orange full-width call-to-action button (Figma "Button 374x"):
/// 60 tall, radius 8, plum bold label. Styling comes from the theme's
/// `filledButtonTheme`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

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
