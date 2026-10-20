import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/courses/application/courses_providers.dart';
import 'package:habit_builder/features/courses/data/fake_course_repository.dart';
import 'package:habit_builder/features/courses/presentation/widgets/course_card.dart';
import 'package:habit_builder/features/courses/presentation/widgets/courses_banner.dart';
import 'package:habit_builder/features/courses/presentation/widgets/sort_bar.dart';
import 'package:habit_builder/features/shell/presentation/widgets/menu_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Courses tab (Figma "Course overview"): banner, sort and filters, and the
/// course cards over the dunes.
class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  bool _searching = false;

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) ref.read(courseQueryProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(courseQueryProvider);
    final courses = ref.watch(visibleCoursesProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -70,
            bottom: 0,
            child: Image.asset(
              AppImages.dunes,
              width: 555,
              height: 543,
              excludeFromSemantics: true,
            ),
          ),
          Column(
            children: [
              AppHeader(
                title: l10n.coursesTitle,
                leading: const MenuButton(),
                trailing: HeaderIconButton(
                  icon: AppIcons.search,
                  tooltip: l10n.coursesSearch,
                  onPressed: _toggleSearch,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    // Figma: the banner starts at y 125.
                    AppHeader.bottomGap + 18,
                    AppSpacing.screen,
                    MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                  ),
                  children: [
                    if (_searching) ...[
                      AppTextField(
                        hintText: l10n.coursesSearchHint,
                        icon: AppIcons.search,
                        textInputAction: TextInputAction.search,
                        onChanged: ref
                            .read(courseQueryProvider.notifier)
                            .setSearch,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ] else ...[
                      CoursesBanner(
                        title: l10n.coursesBannerTitle,
                        body: l10n.coursesBannerBody,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    SortBar(
                      label: l10n.coursesSortBy,
                      sortLabel: _sortLabel(l10n, query.sort),
                      filtersLabel: query.savedOnly
                          ? l10n.coursesFiltersOn
                          : l10n.coursesFilters,
                      onSortTap: () => unawaited(_chooseSort(context)),
                      onFiltersTap: () => unawaited(_chooseFilters(context)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...switch (courses) {
                      AsyncValue(value: final list?) when list.isEmpty => [
                        MessageView(
                          title: l10n.coursesEmptyTitle,
                          body: query.savedOnly
                              ? l10n.coursesEmptySaved
                              : l10n.coursesEmptySearch,
                        ),
                      ],
                      AsyncValue(value: final list?) => [
                        for (final course in list)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: CourseCard(
                              course: course,
                              onTap: () => context.goNamed(
                                AppRoute.courseDetail.name,
                                pathParameters: {'id': course.id},
                              ),
                              onSavedChanged: (saved) => unawaited(
                                ref
                                    .read(courseRepositoryProvider)
                                    .setSaved(course.id, saved: saved),
                              ),
                            ),
                          ),
                      ],
                      AsyncValue(hasError: true) => [
                        MessageView.error(
                          context,
                          onRetry: () => ref.invalidate(coursesProvider),
                        ),
                      ],
                      _ => [const LoadingView()],
                    },
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _sortLabel(AppLocalizations l10n, CourseSort sort) =>
      switch (sort) {
        CourseSort.popular => l10n.coursesSortPopular,
        CourseSort.newest => l10n.coursesSortNewest,
        CourseSort.shortest => l10n.coursesSortShortest,
      };

  Future<void> _chooseSort(BuildContext context) async {
    final l10n = context.l10n;
    final current = ref.read(courseQueryProvider).sort;
    final sort = await showAppSheet<CourseSort>(
      context: context,
      builder: (context) => _ChoiceSheet<CourseSort>(
        title: l10n.coursesSortBy,
        options: {for (final s in CourseSort.values) s: _sortLabel(l10n, s)},
        selected: current,
      ),
    );
    if (sort != null) ref.read(courseQueryProvider.notifier).setSort(sort);
  }

  Future<void> _chooseFilters(BuildContext context) async {
    final l10n = context.l10n;
    final current = ref.read(courseQueryProvider).savedOnly;
    final savedOnly = await showAppSheet<bool>(
      context: context,
      builder: (context) => _ChoiceSheet<bool>(
        title: l10n.coursesFilters,
        options: {false: l10n.coursesFilterAll, true: l10n.coursesFilterSaved},
        selected: current,
      ),
    );
    if (savedOnly != null) {
      ref.read(courseQueryProvider.notifier).setSavedOnly(savedOnly: savedOnly);
    }
  }
}

/// A short list of choices (not in the design), the current one in orange.
class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final Map<T, String> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs,
          children: [
            Text(title, style: AppTextStyles.title),
            for (final MapEntry(:key, :value) in options.entries)
              ListTile(
                title: Text(
                  value,
                  style: key == selected
                      ? AppTextStyles.button.copyWith(color: colors.primaryDark)
                      : AppTextStyles.body,
                ),
                selected: key == selected,
                tileColor: colors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.card,
                ),
                onTap: () => Navigator.of(context).pop(key),
              ),
          ],
        ),
      ),
    );
  }
}
