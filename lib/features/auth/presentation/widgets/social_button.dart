import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

enum SocialProvider {
  google(BrandImages.google),
  facebook(BrandImages.facebook)
  ;

  const SocialProvider(this.logo);

  final String logo;
}

/// White "Continue with …" button (Figma "Button" on Login and Sign Up):
/// 50 pt tall, radius 12, brand logo and bold label.
///
/// The [wide] form (Login) starts the logo 63 pt in and the label 29 pt
/// after it, so the logos of stacked buttons line up; the compact form
/// (Sign Up, side by side) centers logo and label 16 pt apart.
class SocialButton extends StatelessWidget {
  const SocialButton({
    required this.provider,
    required this.label,
    required this.onPressed,
    this.wide = false,
    this.isLoading = false,
    super.key,
  });

  final SocialProvider provider;
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  final bool wide;

  /// Shows a spinner in place of the logo and ignores taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final logo = isLoading
        ? SizedBox.square(
            dimension: _BrandLogo.size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.colors.textPrimary,
            ),
          )
        : _BrandLogo(provider.logo);
    final text = Flexible(
      child: Text(label, style: AppTextStyles.button),
    );
    return Material(
      color: context.colors.surface,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: wide
                ? Row(
                    children: [
                      const SizedBox(width: 63),
                      logo,
                      const SizedBox(width: 29),
                      text,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [logo, const SizedBox(width: 16), text],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The 23 pt logo. Its image is a 55 pt canvas that includes the Figma drop
/// shadow, so it is drawn overflowing the logo's box.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo(this.asset);

  static const size = 23.0;

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -16,
            top: -8,
            width: 55,
            height: 55,
            child: Image.asset(asset, excludeFromSemantics: true),
          ),
        ],
      ),
    );
  }
}
