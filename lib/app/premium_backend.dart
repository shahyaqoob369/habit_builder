import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:habit_builder/features/premium/data/revenuecat_premium_repository.dart';
import 'package:habit_builder/revenuecat_options.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The RevenueCat key for this build: the Test Store (fake purchases) in
/// debug builds, the App Store in iOS release builds. Null where no store
/// is set up yet (Android release builds).
String? get _revenueCatKey {
  if (kDebugMode) return RevenueCatOptions.testStore;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return RevenueCatOptions.appStore;
  }
  return null;
}

/// Sets up RevenueCat and returns the override `main` uses for Premium.
Future<Override> premiumOverride(SharedPreferencesWithCache preferences) async {
  final key = _revenueCatKey;
  if (key == null) {
    return premiumRepositoryProvider.overrideWithValue(
      const UnavailablePremiumRepository(),
    );
  }
  await Purchases.configure(PurchasesConfiguration(key));

  DateTime offerSeenAt(DateTime now) {
    final saved = preferences.getInt(PreferenceKeys.premiumOfferSeenAt);
    if (saved != null) return DateTime.fromMillisecondsSinceEpoch(saved);
    unawaited(
      preferences.setInt(
        PreferenceKeys.premiumOfferSeenAt,
        now.millisecondsSinceEpoch,
      ),
    );
    return now;
  }

  return premiumRepositoryProvider.overrideWith((ref) {
    final auth = ref.watch(
      authStateProvider.select((s) => (known: s.hasValue, uid: s.value?.id)),
    );
    return RevenueCatPremiumRepository(
      uid: auth.uid,
      // Until the saved session loads, leave RevenueCat's user as it is.
      identify: auth.known,
      offerSeenAt: offerSeenAt,
    );
  });
}
