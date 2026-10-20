import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/app/theme/app_theme.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Figma frame: an iPhone 11 Pro Max–sized phone.
const designSize = Size(414, 896);

/// A small phone, for overflow checks.
const smallPhoneSize = Size(375, 667);

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app's theme, localizations and a
  /// [ProviderScope].
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }

  /// Pumps the whole [App] (router included) with test [preferences], a
  /// configurable splash duration (zero by default) and an instant fake
  /// auth backend (or [auth]). Pass [analytics] to check what was logged.
  Future<void> pumpFullApp(
    SharedPreferencesWithCache preferences, {
    Duration splashDuration = Duration.zero,
    AuthRepository? auth,
    Analytics? analytics,
    List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          splashDurationProvider.overrideWithValue(splashDuration),
          authRepositoryProvider.overrideWithValue(
            auth ?? FakeAuthRepository(latency: Duration.zero),
          ),
          if (analytics != null) analyticsProvider.overrideWithValue(analytics),
          ...overrides,
        ],
        child: const App(),
      ),
    );
  }

  /// Scrolls the page's main scroll view until [finder] is fully visible.
  Future<void> scrollPageTo(Finder finder) async {
    await scrollUntilVisible(
      finder,
      100,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await ensureVisible(finder);
    await pumpAndSettle();
  }

  /// Sizes the test screen in logical pixels (3× density), with optional
  /// [textScale]. Restored after the test.
  void useScreen(Size size, {double textScale = 1}) {
    view
      ..devicePixelRatio = 3
      ..physicalSize = size * 3;
    platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(view.reset);
    addTearDown(platformDispatcher.clearTextScaleFactorTestValue);
  }
}
