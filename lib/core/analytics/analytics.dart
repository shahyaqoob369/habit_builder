import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A product event sent to Google Analytics.
///
/// Every event the app logs is a factory here, so the catalog stays in one
/// place. Names follow GA's recommended events where one fits
/// (`tutorial_complete`, `login`, `sign_up`, `share`). Parameters are ids,
/// counts and methods only: never names, emails or text the user wrote.
@immutable
class AnalyticsEvent {
  const AnalyticsEvent._(this.name, [this.parameters = const {}]);

  /// Onboarding finished or skipped.
  const AnalyticsEvent.onboardingComplete() : this._('tutorial_complete');

  /// [method] is `email`, `google` or `apple`.
  AnalyticsEvent.signUp(String method) : this._('sign_up', {'method': method});

  AnalyticsEvent.login(String method) : this._('login', {'method': method});

  AnalyticsEvent.habitCreated({
    required String icon,
    required int days,
    required int reminders,
  }) : this._('habit_created', {
         'icon': icon,
         'days_per_week': days,
         'reminders': reminders,
       });

  const AnalyticsEvent.habitDeleted() : this._('habit_deleted');

  /// [source] is the screen it was marked on: `home` or `detail`.
  AnalyticsEvent.habitCompleted({required int streak, required String source})
    : this._('habit_completed', {'streak': streak, 'source': source});

  AnalyticsEvent.habitMissed({required String source})
    : this._('habit_missed', {'source': source});

  /// The easiness rating (1–10) after completing a habit.
  AnalyticsEvent.habitRated(int score)
    : this._('habit_rated', {'score': score});

  AnalyticsEvent.streakMilestone(int days)
    : this._('streak_milestone', {'days': days});

  AnalyticsEvent.courseOpened(String courseId)
    : this._('course_opened', {'course_id': courseId});

  /// [lesson] is the lesson's number in the course, from 1.
  AnalyticsEvent.lessonOpened({
    required String courseId,
    required int lesson,
    required bool locked,
  }) : this._('lesson_opened', {
         'course_id': courseId,
         'lesson': lesson,
         'locked': locked ? 1 : 0,
       });

  const AnalyticsEvent.postCreated() : this._('post_created');

  AnalyticsEvent.postShared(String postId)
    : this._('share', {'content_type': 'post', 'item_id': postId});

  const AnalyticsEvent.paywallShown() : this._('paywall_shown');

  /// A completed purchase. Revenue comes from the store (RevenueCat), not
  /// from this event.
  AnalyticsEvent.premiumPurchase(String planId)
    : this._('premium_purchase', {'plan_id': planId});

  const AnalyticsEvent.premiumRestore() : this._('premium_restore');

  /// GA event name: snake_case, at most 40 characters.
  final String name;

  /// Strings or numbers only (GA has no booleans).
  final Map<String, Object> parameters;

  @override
  bool operator ==(Object other) =>
      other is AnalyticsEvent &&
      other.name == name &&
      mapEquals(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAllUnordered(
      parameters.entries.map((e) => (e.key, e.value)),
    ),
  );

  @override
  String toString() => 'AnalyticsEvent($name, $parameters)';
}

/// Usage analytics. Calls never throw: analytics must not break the app.
abstract interface class Analytics {
  Future<void> logEvent(AnalyticsEvent event);

  /// [screen] is the route name, such as `home` or `habitDetail`.
  Future<void> logScreenView(String screen);

  /// The user's "Share usage data" choice. Kept by the SDK across launches.
  Future<void> setCollectionEnabled({required bool enabled});
}

/// Keeps events in memory (and prints them in debug builds). The default
/// until `main` overrides [analyticsProvider] with Firebase, so tests never
/// touch Firebase and can check what was logged.
class RecordingAnalytics implements Analytics {
  final events = <AnalyticsEvent>[];
  final screens = <String>[];
  bool collectionEnabled = true;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!collectionEnabled) return;
    events.add(event);
  }

  @override
  Future<void> logScreenView(String screen) async {
    if (!collectionEnabled) return;
    screens.add(screen);
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async =>
      collectionEnabled = enabled;
}

final analyticsProvider = Provider<Analytics>((ref) => RecordingAnalytics());
