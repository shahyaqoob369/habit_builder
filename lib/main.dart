import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/analytics/firebase_analytics_service.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // The design is portrait-only.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final preferences = await createPreferences();
  final analytics = FirebaseAnalyticsService();
  await analytics.setCollectionEnabled(
    enabled: preferences.getBool(PreferenceKeys.shareUsageData) ?? true,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        analyticsProvider.overrideWithValue(analytics),
      ],
      child: const App(),
    ),
  );
}
