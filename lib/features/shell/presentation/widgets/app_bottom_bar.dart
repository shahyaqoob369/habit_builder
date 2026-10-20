import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The app's tabs, in bottom-bar order.
enum AppTab {
  home(NavImages.home, Size(50, 29), 48),
  courses(NavImages.courses, Size(40, 35), 127),
  community(NavImages.community, Size(40, 37), 291),
  settings(NavImages.settings, Size(40, 41), 372)
  ;

  const AppTab(this.image, this.size, this.centerX);

  final String image;

  /// Figma size of the illustration.
  final Size size;

  /// Horizontal center in the 414 pt Figma frame.
  final double centerX;

  String label(AppLocalizations l10n) => switch (this) {
    home => l10n.navHome,
    courses => l10n.navCourses,
    community => l10n.navCommunity,
    settings => l10n.navSettings,
  };
}

/// What the center button does.
enum FabMode {
  /// "+": start a new habit.
  add,

  /// "✓": save the habit being edited.
  save,
}

/// Bottom bar (Figma "Menu" + "Menu Button"): a white bar with a curved
/// notch, four illustrated tabs (the current one in color, the others in
/// grayscale) and the orange round button sitting in the notch.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.currentTab,
    required this.onTabSelected,
    required this.fabMode,
    required this.onFabPressed,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final FabMode fabMode;
  final VoidCallback onFabPressed;

  /// The button overhangs the bar by this much (Figma: button at y 772,
  /// bar at y 816).
  static const fabOverhang = 44.0;

  /// Bar height in the design, which includes the 34 pt home indicator.
  static const _barHeight = 80.0;
  static const _designIndicator = 34.0;

  /// Tab icons are centered this far below the bar's top edge.
  static const _tabCenterY = 44.5;

  /// Total height for the given bottom safe-area inset.
  static double heightFor(double bottomInset) =>
      fabOverhang + _barHeight + math.max(0, bottomInset - _designIndicator);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: heightFor(bottomInset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scaleX = width / 414;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: fabOverhang,
                child: CustomPaint(
                  painter: _BarPainter(color: context.colors.surface),
                ),
              ),
              for (final tab in AppTab.values)
                Positioned(
                  left: tab.centerX * scaleX - _TabButton.width / 2,
                  top: fabOverhang + _tabCenterY - _TabButton.height / 2,
                  child: _TabButton(
                    tab: tab,
                    selected: tab == currentTab,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
              Positioned(
                top: 0,
                left: (width - _CenterButton.size) / 2,
                child: _CenterButton(mode: fabMode, onPressed: onFabPressed),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The bar shape from Figma ("Rectangle", 414 × 80): flat edges and a
/// 175 pt wide, 30 pt deep notch centered under the button. The notch keeps
/// its size; the flat parts stretch with the screen.
class _BarPainter extends CustomPainter {
  const _BarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Notch path from the Figma SVG, relative to its center (x 207).
    final c = size.width / 2;
    double x(double figmaX) => c + figmaX - 207;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x(120.062), 0)
      ..cubicTo(x(137.706), 0, x(155.036), 4.668, x(170.293), 13.531)
      ..lineTo(x(188.741), 24.248)
      ..cubicTo(x(200.191), 30.900, x(214.323), 30.925, x(225.797), 24.314)
      ..lineTo(x(244.825), 13.352)
      ..cubicTo(x(260.008), 4.604, x(277.223), 0, x(294.746), 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => oldDelegate.color != color;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  static const width = 64.0;
  static const height = 48.0;

  /// Luminance-preserving grayscale for the inactive tabs.
  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      tab.image,
      width: tab.size.width,
      height: tab.size.height,
      excludeFromSemantics: true,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label(context.l10n),
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: selected
                ? image
                : ColorFiltered(colorFilter: _grayscale, child: image),
          ),
        ),
      ),
    );
  }
}

/// Figma "Menu Button": a 52 pt orange circle with a glow, inside a 64 pt
/// ring of the same orange at 20 %.
class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.mode, required this.onPressed});

  static const size = 64.0;

  final FabMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: mode == FabMode.add ? l10n.navNewHabit : l10n.navSaveHabit,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryDark.withValues(alpha: 0.2),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryDark,
            boxShadow: AppShadows.fab,
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 52,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: mode == FabMode.add
                        ? AppIcon(
                            AppIcons.plus,
                            key: const ValueKey(FabMode.add),
                            color: colors.textPrimary,
                          )
                        : AppIcon(
                            AppIcons.checkBold,
                            key: const ValueKey(FabMode.save),
                            color: colors.textPrimary,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
