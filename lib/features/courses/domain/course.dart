import 'package:flutter/foundation.dart';

/// A video lesson in a course.
@immutable
class Lesson {
  const Lesson({
    required this.title,
    required this.duration,
    this.isFree = false,
  });

  final String title;
  final Duration duration;

  /// Free lessons play for everyone; the rest need Premium.
  final bool isFree;
}

/// A habit course (Figma "Course overview", "Course – what's inside").
@immutable
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.image,
    required this.lessons,
    required this.popularity,
    required this.publishedAt,
    this.isSaved = false,
  });

  final String id;
  final String title;

  /// Cover image: an asset path for the sample courses, later a URL.
  final String image;

  final List<Lesson> lessons;

  /// Higher is more popular ("Sort By: Popular").
  final int popularity;
  final DateTime publishedAt;

  /// Bookmarked by the user.
  final bool isSaved;

  Duration get duration =>
      lessons.fold(Duration.zero, (total, lesson) => total + lesson.duration);

  Course copyWith({bool? isSaved}) => Course(
    id: id,
    title: title,
    image: image,
    lessons: lessons,
    popularity: popularity,
    publishedAt: publishedAt,
    isSaved: isSaved ?? this.isSaved,
  );
}
