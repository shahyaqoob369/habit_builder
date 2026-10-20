import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/features/courses/domain/course.dart';
import 'package:habit_builder/features/courses/domain/course_repository.dart';

/// In-memory [CourseRepository] with the design's two sample courses. Used
/// until the courses backend (plan step 23).
class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository() : _courses = _samples();

  List<Course> _courses;
  final _changes = StreamController<List<Course>>.broadcast();

  @override
  Stream<List<Course>> watchCourses() {
    StreamSubscription<List<Course>>? changes;
    late final StreamController<List<Course>> controller;
    controller = StreamController<List<Course>>(
      onListen: () {
        controller.add(_courses);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  @override
  Future<void> setSaved(String id, {required bool saved}) async {
    _courses = List.unmodifiable([
      for (final c in _courses) c.id == id ? c.copyWith(isSaved: saved) : c,
    ]);
    _changes.add(_courses);
  }

  static List<Course> _samples() {
    Lesson lesson(
      String title,
      int minutes,
      int seconds, {
      bool free = false,
    }) => Lesson(
      title: title,
      duration: Duration(minutes: minutes, seconds: seconds),
      isFree: free,
    );

    // 37 lessons, 2 h 41 m in all, as on the design's card.
    final journal = [
      lesson('Introduction', 2, 16, free: true),
      lesson('Adopting Prompts to Your Day', 3, 8),
      lesson('Choosing a Notebook', 6, 6),
      lesson('Optional Supplies', 2, 4),
      lesson('Day 1', 3, 38),
      for (var day = 2; day <= 30; day++) lesson('Day $day', 4, 40),
      lesson('Looking Back', 3, 0),
      lesson('Keeping It Going', 3, 0),
      lesson('Wrap-up', 2, 28),
    ];
    // 24 lessons, 4 h 6 m.
    final selfHelp = [
      lesson('Why Habits Matter', 6, 2, free: true),
      for (var i = 2; i <= 24; i++) lesson('Lesson $i', 10, 26),
    ];
    return List.unmodifiable([
      Course(
        id: 'journal-challenge',
        title:
            '30 Day Journal Challenge - Establish a Habit of Daily '
            'Journaling',
        image: CourseImages.journalChallenge,
        lessons: List.unmodifiable(journal),
        popularity: 98,
        publishedAt: DateTime(2026, 6),
      ),
      Course(
        id: 'self-help-series',
        title: 'Self Help Series: How to Create and Maintain Good Habits',
        image: CourseImages.selfHelpSeries,
        lessons: List.unmodifiable(selfHelp),
        popularity: 87,
        publishedAt: DateTime(2026, 8),
      ),
    ]);
  }
}

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => FakeCourseRepository(),
);
