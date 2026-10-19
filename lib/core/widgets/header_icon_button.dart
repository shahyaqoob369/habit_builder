import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';

/// Round header button (Figma "Icons": Back, Help, …): a 44 pt plum circle
/// at 10 % opacity with the icon centered.
///
/// Its touch target is 48 pt, so it reaches [inset] beyond the circle on
/// every side; subtract that from the padding when placing it.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  /// How far the touch target extends beyond the visible circle.
  static const inset = 2.0;

  /// Space above a header button so that its circle starts right below the
  /// status bar. (Figma puts it 5 pt higher, under a 44 pt status bar; on
  /// Android's 24 pt bar that would crowd the status icons.)
  static double topGap(BuildContext context) =>
      math.max(0, MediaQuery.paddingOf(context).top - inset);

  /// An `AppIcons` asset.
  final String icon;

  /// Accessible name, also shown on long press.
  final String tooltip;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: AppIcon(icon, color: colors.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
        fixedSize: const Size.square(44),
        minimumSize: const Size.square(44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}
