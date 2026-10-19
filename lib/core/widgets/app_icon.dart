import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// A single-color SVG icon from `AppIcons`, drawn at its Figma size and
/// tinted with [color] (the ambient [IconTheme] color, or `textPrimary`).
///
/// Decorative: screen readers skip it; label the control around it instead.
class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {this.color, super.key});

  final String asset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint =
        color ?? IconTheme.of(context).color ?? context.colors.textPrimary;
    return SvgPicture.asset(
      asset,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}
