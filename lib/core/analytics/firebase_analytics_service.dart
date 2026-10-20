import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/analytics/analytics.dart';

/// [Analytics] backed by Google Analytics for Firebase.
class FirebaseAnalyticsService implements Analytics {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(AnalyticsEvent event) => _guard(
    () => _analytics.logEvent(
      name: event.name,
      parameters: event.parameters.isEmpty ? null : event.parameters,
    ),
  );

  @override
  Future<void> logScreenView(String screen) => _guard(
    () => _analytics.logScreenView(screenName: screen, screenClass: screen),
  );

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _guard(() => _analytics.setAnalyticsCollectionEnabled(enabled));

  static Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on Object catch (error) {
      // Analytics must never break the app.
      debugPrint('Analytics call failed: $error');
    }
  }
}
