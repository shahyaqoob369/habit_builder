import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/app/theme/app_theme.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Pumps the whole [App] (router included) with test [preferences] and a
  /// configurable splash duration (zero by default).
  Future<void> pumpFullApp(
    SharedPreferencesWithCache preferences, {
    Duration splashDuration = Duration.zero,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          splashDurationProvider.overrideWithValue(splashDuration),
        ],
        child: const App(),
      ),
    );
  }
}
