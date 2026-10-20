import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/courses/application/courses_providers.dart';
import 'package:habit_builder/features/courses/domain/course.dart';
import 'package:habit_builder/features/courses/presentation/course_format.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Course detail (Figma "Course – what's inside"): the video header and
/// the lesson list. The first lesson is free; the rest need Premium.
class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  /// Lessons shown before "Show all".
  static const previewCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final courses = ref.watch(coursesProvider);
    final course = courses.value?.where((c) => c.id == courseId).firstOrNull;

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: course?.title ?? '',
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: switch (courses) {
              AsyncValue(hasValue: true) when course == null => MessageView(
                title: l10n.courseNotFoundTitle,
                body: l10n.courseNotFoundBody,
              ),
              AsyncValue(hasValue: true) => _CourseContent(course: course!),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(coursesProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }
}

class _CourseContent extends StatefulWidget {
  const _CourseContent({required this.course});

  final Course course;

  @override
  State<_CourseContent> createState() => _CourseContentState();
}

class _CourseContentState extends State<_CourseContent> {
  bool _showAll = false;

  void _open(Lesson lesson) {
    final l10n = context.l10n;
    // Video playback arrives with the courses backend (plan step 22), and
    // the paywall in step 12.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            lesson.isFree ? l10n.lessonComingSoon : l10n.lessonLocked,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final course = widget.course;
    final lessons = _showAll
        ? course.lessons
        : course.lessons.take(CourseDetailPage.previewCount).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        // Figma: the video starts at y 121.
        AppHeader.bottomGap + 14,
        AppSpacing.screen,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
      ),
      children: [
        _VideoHeader(
          image: course.image,
          label: l10n.lessonPlay(course.lessons.first.title),
          onTap: () => _open(course.lessons.first),
        ),
        const SizedBox(height: 11),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 25, 17, 18),
                child: Text(course.title, style: AppTextStyles.cardTitle),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 18, 17, 17),
                child: Text(
                  l10n.courseLessonsLength(
                    course.lessons.length,
                    formatCourseLength(l10n, course.duration),
                  ),
                  style: AppTextStyles.bodyStrong,
                ),
              ),
              for (final (i, lesson) in lessons.indexed) ...[
                const Divider(),
                _LessonRow(
                  number: i + 1,
                  lesson: lesson,
                  onTap: () => _open(lesson),
                ),
              ],
              if (!_showAll && course.lessons.length > lessons.length) ...[
                const Divider(),
                TextButton(
                  onPressed: () => setState(() => _showAll = true),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primaryDark,
                    textStyle: AppTextStyles.button,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(l10n.courseShowAll(course.lessons.length)),
                ),
              ] else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

/// Course photo with a dark fade and the round play button.
class _VideoHeader extends StatelessWidget {
  const _VideoHeader({
    required this.image,
    required this.label,
    required this.onTap,
  });

  final String image;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final white = context.colors.surface;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        borderRadius: AppRadii.card,
        clipBehavior: Clip.antiAlias,
        child: Ink.image(
          image: AssetImage(image),
          height: 200,
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0x40000000),
            BlendMode.darken,
          ),
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: white, width: 1.5),
                  color: white.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.play_arrow_rounded, color: white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.number,
    required this.lesson,
    required this.onTap,
  });

  final int number;
  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label:
          '$number. ${lesson.title}, '
          '${formatLessonLength(lesson.duration)}'
          '${lesson.isFree ? '' : ', ${l10n.lessonLockedLabel}'}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 49,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, right: 16),
            child: Row(
              children: [
                AppIcon.original(
                  lesson.isFree ? AppIcons.lessonPlay : AppIcons.lessonLocked,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '$number.  ${lesson.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  formatLessonLength(lesson.duration),
                  style: AppTextStyles.body.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
