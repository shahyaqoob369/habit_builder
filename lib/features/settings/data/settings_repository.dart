import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's app settings (not in the design beyond the two rows).
@immutable
class AppSettings {
  const AppSettings({
    this.habitReminders = true,
    this.communityNotifications = true,
    this.showQuote = true,
  });

  /// Master switch for habit reminder notifications.
  final bool habitReminders;

  /// Likes and comments on my posts.
  final bool communityNotifications;

  /// The quote card on Home.
  final bool showQuote;
}

/// Settings kept on this device.
class SettingsController extends Notifier<AppSettings> {
  SharedPreferencesWithCache get _preferences =>
      ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      habitReminders:
          preferences.getBool(PreferenceKeys.habitReminders) ?? true,
      communityNotifications:
          preferences.getBool(PreferenceKeys.communityNotifications) ?? true,
      showQuote: preferences.getBool(PreferenceKeys.showQuote) ?? true,
    );
  }

  Future<void> setHabitReminders({required bool enabled}) =>
      _set(PreferenceKeys.habitReminders, enabled);

  Future<void> setCommunityNotifications({required bool enabled}) =>
      _set(PreferenceKeys.communityNotifications, enabled);

  Future<void> setShowQuote({required bool enabled}) =>
      _set(PreferenceKeys.showQuote, enabled);

  Future<void> _set(String key, bool value) async {
    await _preferences.setBool(key, value);
    ref.invalidateSelf();
  }
}

final NotifierProvider<SettingsController, AppSettings> settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
