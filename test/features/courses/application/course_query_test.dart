import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/courses/application/courses_providers.dart';
import 'package:habit_builder/features/courses/domain/course.dart';

void main() {
  Course course(
    String id, {
    int popularity = 0,
    int month = 1,
    int minutes = 10,
    bool saved = false,
  }) => Course(
    id: id,
    title: 'Course $id',
    image: '',
    lessons: [
      Lesson(
        title: 'L',
        duration: Duration(minutes: minutes),
      ),
    ],
    popularity: popularity,
    publishedAt: DateTime(2026, month),
    isSaved: saved,
  );

  final courses = [
    course('a', popularity: 5, month: 3, minutes: 30),
    course('b', popularity: 9, saved: true),
    course('c', popularity: 1, month: 6, minutes: 20),
  ];

  List<String> ids(CourseQuery q) => q.apply(courses).map((c) => c.id).toList();

  group('CourseQuery', () {
    test('sorts by popularity, date or length', () {
      expect(ids(const CourseQuery()), ['b', 'a', 'c']);
      expect(ids(const CourseQuery(sort: CourseSort.newest)), ['c', 'a', 'b']);
      expect(ids(const CourseQuery(sort: CourseSort.shortest)), [
        'b',
        'c',
        'a',
      ]);
    });

    test('filters saved courses and searches titles', () {
      expect(ids(const CourseQuery(savedOnly: true)), ['b']);
      expect(ids(const CourseQuery(search: ' course C ')), ['c']);
    });
  });
}
