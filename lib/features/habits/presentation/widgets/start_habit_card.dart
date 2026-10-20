import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';

/// "Start this habit" tip (Figma "Message Popup"): a white card with the
/// round avatar over its top edge and a hand-drawn arrow pointing at the ✓
/// button below.
class StartHabitCard extends StatelessWidget {
  const StartHabitCard({required this.title, required this.body, super.key});

  final String title;
  final String body;

  static const _avatar = 70.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: _avatar / 2),
          padding: const EdgeInsets.fromLTRB(12, 51, 12, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.card,
          ),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.note.copyWith(color: colors.textMuted),
                ),
              ),
              const SizedBox(height: 17),
              AppIcon(AppIcons.handArrow, color: colors.textPrimary),
            ],
          ),
        ),
        ClipOval(
          child: Image.asset(
            HabitImages.startAvatar,
            width: _avatar,
            height: _avatar,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}
