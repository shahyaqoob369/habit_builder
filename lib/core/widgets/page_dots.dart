import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// Page indicator from the onboarding design: the current page is a plum dot
/// inside a faint plum ring (17 pt), the others are light-orange dots
/// (11 pt), 7 pt apart.
class PageDots extends StatelessWidget {
  const PageDots({
    required this.count,
    required this.index,
    required this.semanticsLabel,
    super.key,
  });

  final int count;
  final int index;

  /// Screen-reader label, for example "Page 2 of 4".
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          for (var i = 0; i < count; i++) _Dot(isActive: i == index),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  static const _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = isActive ? 17.0 : 11.0;
    final dotSize = isActive ? 13.0 : 11.0;
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOut,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? colors.textPrimary.withValues(alpha: 0.2)
            : colors.textPrimary.withValues(alpha: 0),
      ),
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? colors.textPrimary : colors.primaryLight,
          boxShadow: AppShadows.card,
        ),
      ),
    );
  }
}
