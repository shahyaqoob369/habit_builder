import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';

/// A tappable line of 14 pt text, in one of the design's two forms:
///
/// * without [prompt], the underlined [label] ("Forgot Password?");
/// * with [prompt], the plain prompt then the bold [label]
///   ("Don’t have an account? **Sign up**").
///
/// The touch target reaches [padding] around the text: 8 pt to the sides
/// and 3 pt above and below. Subtract the 3 pt from the gaps around it.
class TextLink extends StatelessWidget {
  const TextLink({
    required this.label,
    required this.onTap,
    this.prompt,
    super.key,
  });

  static const padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: 3,
  );

  final String label;
  final String? prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final prompt = this.prompt;
    final text = prompt == null
        ? Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.helper.copyWith(
              decoration: TextDecoration.underline,
            ),
          )
        : Text.rich(
            TextSpan(
              text: '$prompt ',
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.helper,
          );
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Padding(padding: padding, child: text),
      ),
    );
  }
}
