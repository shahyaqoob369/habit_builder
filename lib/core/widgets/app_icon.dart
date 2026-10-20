import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// An SVG icon from `AppIcons`, drawn at its Figma size unless [size] is
/// given.
///
/// The default constructor tints a single-color glyph with [color] (the
/// ambient [IconTheme] color, or `textPrimary`); [AppIcon.original] draws a
/// full-color icon as designed.
///
/// Decorative: screen readers skip it; label the control around it instead.
class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {this.color, this.size, super.key}) : tinted = true;

  const AppIcon.original(this.asset, {this.size, super.key})
    : color = null,
      tinted = false;

  final String asset;
  final Color? color;

  /// Width and height of a square box to fit the icon in.
  final double? size;

  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final tint = tinted
        ? color ?? IconTheme.of(context).color ?? context.colors.textPrimary
        : null;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}
