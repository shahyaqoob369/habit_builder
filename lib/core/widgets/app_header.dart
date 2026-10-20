import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';

/// Screen header from the design: a round button on each side and the title
/// centered between them (Manrope 700 18/32), right below the status bar.
///
/// [leading] and [trailing] are usually [HeaderIconButton]s; an empty side
/// keeps its space so the title stays centered.
class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  /// Height of the header row: the buttons' touch target.
  static const height = 48.0;

  /// Space between the bottom of the header row and the content below it.
  ///
  /// Figma puts content 24 pt below the circles, but its circles sit 5 pt
  /// higher than ours (see [HeaderIconButton.topGap]); 19 pt keeps the
  /// content at its Figma position. The row is 2 pt taller than the circle.
  static const double bottomGap = 19 - HeaderIconButton.inset;

  @override
  Widget build(BuildContext context) {
    const side = SizedBox.square(dimension: height);
    return Padding(
      padding: EdgeInsets.only(
        top: HeaderIconButton.topGap(context),
        left: AppSpacing.screen - HeaderIconButton.inset,
        right: AppSpacing.screen - HeaderIconButton.inset,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            leading ?? side,
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ),
            ),
            trailing ?? side,
          ],
        ),
      ),
    );
  }
}
