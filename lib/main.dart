import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/analytics/firebase_analytics_service.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/data/firestore_habit_repository.dart';
import 'package:habit_builder/firebase_options.dart';

/// Debug builds can skip Firebase sign-in and start signed in as the demo
/// user, for checking screens on a simulator:
/// `flutter run --dart-define=FAKE_AUTH=true --dart-define=INITIAL_ROUTE=/home`.
const bool _debugFakeAuth = kDebugMode && bool.fromEnvironment('FAKE_AUTH');

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
        if (_debugFakeAuth)
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(signedIn: true),
          )
        else
          ..._firebaseOverrides,
      ],
      child: const App(),
    ),
  );
}

/// The Firebase-backed repositories. The providers' defaults are in-memory
/// fakes, which tests (and `FAKE_AUTH`) use.
List<Override> get _firebaseOverrides => [
  authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
  habitRepositoryProvider.overrideWith((ref) {
    // Only a different user (not a renamed one) needs a new repository.
    final uid = ref.watch(authStateProvider.select((user) => user.value?.id));
    return uid == null
        ? const SignedOutHabitRepository()
        : FirestoreHabitRepository(uid: uid);
  }),
];
