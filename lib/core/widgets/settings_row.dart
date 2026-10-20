import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/chevron.dart';

/// A white settings row (Figma "Setting 7–12"): a 38 pt icon tile, a title
/// with an optional subtitle, an optional value and a chevron. 50 pt tall,
/// 74 with a subtitle.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// Shown on the 10 % orange tile. A full-color tile icon (38 pt, with its
  /// own background) can be passed as is.
  final Widget icon;

  final String title;
  final String? subtitle;

  /// Bold text before the chevron ("20 Days").
  final String? value;

  /// Replaces the chevron (a toggle, for example).
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = this.subtitle;
    final value = this.value;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: subtitle == null ? 50 : 74),
          child: Padding(
            padding: EdgeInsets.fromLTRB(subtitle == null ? 6 : 8, 6, 20, 6),
            child: Row(
              children: [
                icon,
                SizedBox(width: subtitle == null ? 14 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(title, style: AppTextStyles.body),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: AppTextStyles.label.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (value != null) ...[
                  Text(value, style: AppTextStyles.button),
                  const SizedBox(width: 10),
                ],
                trailing ?? Chevron(color: colors.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 38 pt rounded tile in 10 % orange that holds a row's glyph.
class IconTile extends StatelessWidget {
  const IconTile({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadii.card,
      ),
      child: child,
    );
  }
}
