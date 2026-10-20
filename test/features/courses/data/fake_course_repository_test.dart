import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/courses/data/fake_course_repository.dart';
import 'package:habit_builder/features/courses/presentation/course_format.dart';

void main() {
  test("sample courses match the design's cards", () async {
    final courses = await FakeCourseRepository().watchCourses().first;

    expect(courses.first.lessons, hasLength(37));
    expect(courses.first.duration, const Duration(hours: 2, minutes: 41));
    expect(courses.last.lessons, hasLength(24));
    expect(courses.last.duration, const Duration(hours: 4, minutes: 6));
    expect(courses.first.lessons.first.isFree, isTrue);
    expect(courses.first.lessons[1].isFree, isFalse);
  });

  test('saving a course is emitted', () async {
    final repository = FakeCourseRepository();
    final next = repository.watchCourses().skip(1).first;

    await repository.setSaved('self-help-series', saved: true);

    expect((await next).last.isSaved, isTrue);
  });

  test('lesson lengths print as m:ss', () {
    expect(formatLessonLength(const Duration(minutes: 2, seconds: 6)), '2:06');
  });
}
