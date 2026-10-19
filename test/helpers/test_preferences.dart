import 'package:habit_builder/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// A real [SharedPreferencesWithCache] backed by memory, seeded with
/// [values]. Call it in `setUp`, outside the widget tester's fake async zone.
Future<SharedPreferencesWithCache> createTestPreferences([
  Map<String, Object> values = const {},
]) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
  return createPreferences();
}
