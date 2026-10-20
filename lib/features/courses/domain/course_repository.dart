import 'package:habit_builder/features/courses/domain/course.dart';

/// Where courses come from. A fake with sample courses for now; the
/// courses backend arrives in plan step 23.
abstract interface class CourseRepository {
  /// All courses, re-emitted when one is saved or unsaved.
  Stream<List<Course>> watchCourses();

  /// Bookmarks (or un-bookmarks) course [id].
  Future<void> setSaved(String id, {required bool saved});
}
