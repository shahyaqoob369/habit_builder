import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/courses/data/fake_course_repository.dart';
import 'package:habit_builder/features/courses/domain/course.dart';

/// "Sort By" options (only "Popular" is in the design).
enum CourseSort { popular, newest, shortest }

/// What the Courses list shows: sort order, saved-only filter and search.
@immutable
class CourseQuery {
  const CourseQuery({
    this.sort = CourseSort.popular,
    this.savedOnly = false,
    this.search = '',
  });

  final CourseSort sort;
  final bool savedOnly;
  final String search;

  CourseQuery copyWith({CourseSort? sort, bool? savedOnly, String? search}) =>
      CourseQuery(
        sort: sort ?? this.sort,
        savedOnly: savedOnly ?? this.savedOnly,
        search: search ?? this.search,
      );

  /// [courses] filtered and sorted.
  List<Course> apply(List<Course> courses) {
    final term = search.trim().toLowerCase();
    final result = [
      for (final course in courses)
        if ((!savedOnly || course.isSaved) &&
            (term.isEmpty || course.title.toLowerCase().contains(term)))
          course,
    ];
    switch (sort) {
      case CourseSort.popular:
        result.sort((a, b) => b.popularity.compareTo(a.popularity));
      case CourseSort.newest:
        result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      case CourseSort.shortest:
        result.sort((a, b) => a.duration.compareTo(b.duration));
    }
    return result;
  }
}

class CourseQueryController extends Notifier<CourseQuery> {
  @override
  CourseQuery build() => const CourseQuery();

  void setSort(CourseSort sort) => state = state.copyWith(sort: sort);

  void setSavedOnly({required bool savedOnly}) =>
      state = state.copyWith(savedOnly: savedOnly);

  void setSearch(String search) => state = state.copyWith(search: search);
}

final NotifierProvider<CourseQueryController, CourseQuery> courseQueryProvider =
    NotifierProvider<CourseQueryController, CourseQuery>(
      CourseQueryController.new,
    );

/// Every course.
final StreamProvider<List<Course>> coursesProvider =
    StreamProvider<List<Course>>(
      (ref) => ref.watch(courseRepositoryProvider).watchCourses(),
    );

/// The courses to list, after [courseQueryProvider].
final Provider<AsyncValue<List<Course>>> visibleCoursesProvider =
    Provider<AsyncValue<List<Course>>>((ref) {
      final query = ref.watch(courseQueryProvider);
      return ref.watch(coursesProvider).whenData(query.apply);
    });
