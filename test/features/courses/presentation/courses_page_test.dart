import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/courses/data/fake_course_repository.dart';
import 'package:habit_builder/features/courses/presentation/course_detail_page.dart';
import 'package:habit_builder/features/courses/presentation/courses_page.dart';
import 'package:habit_builder/features/courses/presentation/widgets/course_card.dart';
import 'package:habit_builder/features/courses/presentation/widgets/courses_banner.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const journal =
      '30 Day Journal Challenge - Establish a Habit of Daily '
      'Journaling';
  const selfHelp = 'Self Help Series: How to Create and Maintain Good Habits';

  group('CoursesPage', () {
    Future<void> pumpCourses(WidgetTester tester) async {
      tester
        ..useScreen(const Size(414, 1031))
        ..view.padding = const FakeViewPadding(top: 44 * 3);
      await tester.pumpApp(
        const CoursesPage(),
        overrides: [
          courseRepositoryProvider.overrideWithValue(FakeCourseRepository()),
        ],
      );
      await tester.pump();
    }

    List<String> titles(WidgetTester tester) => tester
        .widgetList<CourseCard>(find.byType(CourseCard))
        .map((c) => c.course.title)
        .toList();

    testWidgets('lays out banner, sort bar and cards as in Figma', (
      tester,
    ) async {
      await pumpCourses(tester);

      expect(tester.getTopLeft(find.byType(CoursesBanner)).dy, 125);
      expect(tester.getTopLeft(find.text('Sort By:')).dy, closeTo(304, 0.5));
      expect(tester.getTopLeft(find.byType(CourseCard).first).dy, 344);
      expect(find.text('HABIT COURSES'), findsOneWidget);
      expect(find.text('2h 41m'), findsOneWidget);
      expect(find.text('37 Lessons'), findsOneWidget);
    });

    testWidgets('sorting by newest reorders the list', (tester) async {
      await pumpCourses(tester);
      expect(titles(tester), [journal, selfHelp]);

      await tester.tap(find.text('Popular'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Newest'));
      await tester.pumpAndSettle();

      expect(titles(tester), [selfHelp, journal]);
    });

    testWidgets('saved filter shows only bookmarked courses', (tester) async {
      await pumpCourses(tester);

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved courses only'));
      await tester.pumpAndSettle();
      expect(find.text('NO COURSES HERE'), findsOneWidget);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All courses'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Save course').first);
      await tester.pump();
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved courses only'));
      await tester.pumpAndSettle();

      expect(titles(tester), [journal]);
    });

    testWidgets('search filters by title', (tester) async {
      await pumpCourses(tester);

      await tester.tap(find.byTooltip('Search courses'));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'self help');
      await tester.pump();

      expect(titles(tester), [selfHelp]);
      expect(find.byType(CoursesBanner), findsNothing);
    });
  });

  group('CourseDetailPage', () {
    Future<void> pumpDetail(WidgetTester tester, String id) async {
      tester
        ..useScreen(designSize)
        ..view.padding = const FakeViewPadding(top: 44 * 3);
      await tester.pumpApp(
        CourseDetailPage(courseId: id),
        overrides: [
          courseRepositoryProvider.overrideWithValue(FakeCourseRepository()),
        ],
      );
      await tester.pump();
    }

    testWidgets('lists the first five lessons, then all of them', (
      tester,
    ) async {
      await pumpDetail(tester, 'journal-challenge');

      expect(find.text('37 Lessons (2h 41m)'), findsOneWidget);
      expect(tester.getTopLeft(find.text('37 Lessons (2h 41m)')).dy, 444);
      expect(find.text('1.  Introduction'), findsOneWidget);
      expect(find.text('5.  Day 1'), findsOneWidget);
      expect(find.text('6.  Day 2'), findsNothing);

      await tester.scrollUntilVisible(find.text('Show all 37 lessons'), 100);
      await tester.tap(find.text('Show all 37 lessons'));
      await tester.pump();
      expect(find.text('6.  Day 2'), findsOneWidget);
    });

    testWidgets('a locked lesson explains Premium', (tester) async {
      await pumpDetail(tester, 'journal-challenge');

      await tester.tap(find.text('2.  Adopting Prompts to Your Day'));
      await tester.pump();

      expect(find.text('This lesson is part of Premium.'), findsOneWidget);
    });

    testWidgets('an unknown course shows a message', (tester) async {
      await pumpDetail(tester, 'nope');

      expect(find.text('COURSE NOT FOUND'), findsOneWidget);
    });
  });
}
