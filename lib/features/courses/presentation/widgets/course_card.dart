import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/features/courses/domain/course.dart';
import 'package:habit_builder/features/courses/presentation/course_format.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// A course in the list (Figma "Course 1/2"): photo, title, length,
/// lesson count and the bookmark button.
class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    required this.onTap,
    required this.onSavedChanged,
    super.key,
  });

  final Course course;
  final VoidCallback onTap;
  final ValueChanged<bool> onSavedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              course.image,
              height: 166,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              formatCourseLength(l10n, course.duration),
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              l10n.courseLessons(course.lessons.length),
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BookmarkButton(
                        saved: course.isSaved,
                        onChanged: onSavedChanged,
                      ),
                    ],
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

/// Round 32 pt bookmark toggle; orange when saved.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    required this.saved,
    required this.onChanged,
    super.key,
  });

  final bool saved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      toggled: saved,
      label: l10n.courseSave,
      excludeSemantics: true,
      onTap: () => onChanged(!saved),
      child: InkResponse(
        onTap: () => onChanged(!saved),
        radius: 24,
        child: AppIcon(
          AppIcons.bookmark,
          color: saved ? colors.primaryDark : colors.textPrimary,
        ),
      ),
    );
  }
}
