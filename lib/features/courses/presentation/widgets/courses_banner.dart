import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';

/// "Habit courses" banner (Figma "Header"): illustration with an orange
/// fade, the big title and a line of text.
class CoursesBanner extends StatelessWidget {
  const CoursesBanner({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.large,
      child: SizedBox(
        height: 146,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              CourseImages.banner,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              excludeFromSemantics: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 22, 120, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: AppTextStyles.displayMedium),
                  const SizedBox(height: 1),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 212),
                      child: Text(body, style: AppTextStyles.bannerBody),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
