import 'package:flutter/material.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The user's avatar in a header (Home, Community). [onTap] opens the
/// profile.
class ProfileButton extends StatelessWidget {
  const ProfileButton({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: context.l10n.homeProfileTooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image.asset(
              AppImages.avatar,
              width: 44,
              height: 44,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
