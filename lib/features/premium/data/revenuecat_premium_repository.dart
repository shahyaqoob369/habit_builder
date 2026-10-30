import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// [PremiumRepository] on RevenueCat (see docs/REVENUECAT.md): the current
/// offering's packages are the plans, and the `premium` entitlement is
/// Premium.
///
/// Purchases belong to the signed-in Firebase user (`uid`), so Premium
/// follows the account to other devices. `main` configures the SDK first.
class RevenueCatPremiumRepository implements PremiumRepository {
  RevenueCatPremiumRepository({
    required String? uid,
    required this.offerSeenAt,
    bool identify = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _ready = identify ? _identify(uid) : Future.value();
  }

  /// The entitlement every plan unlocks.
  static const entitlement = 'premium';

  /// When this device first saw the time-limited offer; saves `now` if
  /// it hasn't yet.
  final DateTime Function(DateTime now) offerSeenAt;

  final DateTime Function() _clock;
  late final Future<void> _ready;

  /// The packages of the last offering shown, by plan id.
  final Map<String, Package> _packages = {};

  static Future<void> _identify(String? uid) async {
    try {
      if (uid != null) {
        await Purchases.logIn(uid);
      } else if (!await Purchases.isAnonymous) {
        await Purchases.logOut();
      }
    } on PlatformException catch (e) {
      // Purchases still work; they're linked once the SDK reaches the server.
      debugPrint('RevenueCat identify failed: ${e.message}');
    }
  }

  @override
  Future<PremiumOffering> offering() async {
    await _ready;
    final current = (await Purchases.getOfferings()).current;
    if (current == null) throw const PurchaseException(PurchaseFailure.unknown);
    final offering = premiumOfferingFrom(
      current,
      offerSeenAt: offerSeenAt,
      now: _clock(),
    );
    _packages
      ..clear()
      ..addEntries(
        current.availablePackages.map((p) => MapEntry(p.identifier, p)),
      );
    return offering;
  }

  @override
  Stream<bool> watchIsPremium() {
    late final StreamController<bool> controller;
    void onInfo(CustomerInfo info) => controller.add(_isPremium(info));
    controller = StreamController<bool>(
      onListen: () async {
        Purchases.addCustomerInfoUpdateListener(onInfo);
        await _ready;
        try {
          onInfo(await Purchases.getCustomerInfo());
        } on PlatformException catch (e) {
          debugPrint('RevenueCat customer info failed: ${e.message}');
        }
      },
      onCancel: () => Purchases.removeCustomerInfoUpdateListener(onInfo),
    );
    return controller.stream.distinct();
  }

  @override
  Future<void> purchase(PremiumPlan plan) async {
    await _ready;
    final package = _packages[plan.id];
    if (package == null) throw const PurchaseException(PurchaseFailure.unknown);
    await _guard(() => Purchases.purchase(PurchaseParams.package(package)));
  }

  @override
  Future<void> restore() async {
    await _ready;
    final info = await _guard(Purchases.restorePurchases);
    if (!_isPremium(info)) {
      throw const PurchaseException(PurchaseFailure.nothingToRestore);
    }
  }

  static bool _isPremium(CustomerInfo info) =>
      info.entitlements.active.containsKey(entitlement);

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw const PurchaseException(PurchaseFailure.cancelled);
      }
      debugPrint('RevenueCat purchase failed: $code ${e.message}');
      throw const PurchaseException(PurchaseFailure.unknown);
    }
  }
}

/// How long a time-limited offer lasts after the paywall first shows it.
const offerDuration = Duration(hours: 24);

/// Turns a RevenueCat offering into the paywall's plans.
///
/// The offering's metadata (edited in the RevenueCat dashboard, no app
/// update needed) can set:
/// - `most_popular`: the package id with the "Most Popular" header;
/// - `badges`: package id → corner badge, e.g. `{"$rc_lifetime": "-75%"}`;
/// - `offer_percent`: shows the "60 % off" countdown card. Only set it
///   while the store really sells the plans at that discount.
@visibleForTesting
PremiumOffering premiumOfferingFrom(
  Offering offering, {
  required DateTime Function(DateTime now) offerSeenAt,
  required DateTime now,
}) {
  final metadata = offering.metadata;
  final mostPopular = metadata['most_popular'];
  final badges = metadata['badges'];
  final offerPercent = metadata['offer_percent'];
  final plans = [
    for (final package in offering.availablePackages)
      if (_periods[package.packageType] case final period?)
        PremiumPlan(
          id: package.identifier,
          period: period,
          price: package.storeProduct.priceString,
          isMostPopular: package.identifier == mostPopular,
          badge: badges is Map ? badges[package.identifier] as String? : null,
        ),
  ];
  if (offerPercent is! num) return PremiumOffering(plans: plans);
  final expiresAt = offerSeenAt(now).add(offerDuration);
  return PremiumOffering(
    plans: plans,
    discountPercent: expiresAt.isAfter(now) ? offerPercent.round() : null,
    expiresAt: expiresAt.isAfter(now) ? expiresAt : null,
  );
}

const Map<PackageType, PlanPeriod> _periods = {
  PackageType.monthly: PlanPeriod.monthly,
  PackageType.annual: PlanPeriod.yearly,
  PackageType.lifetime: PlanPeriod.lifetime,
};

/// Used where the store isn't set up yet (Android release builds): no
/// plans, never Premium.
class UnavailablePremiumRepository implements PremiumRepository {
  const UnavailablePremiumRepository();

  @override
  Future<PremiumOffering> offering() =>
      Future.error(const PurchaseException(PurchaseFailure.unknown));

  @override
  Stream<bool> watchIsPremium() => Stream.value(false);

  @override
  Future<void> purchase(PremiumPlan plan) =>
      Future.error(const PurchaseException(PurchaseFailure.unknown));

  @override
  Future<void> restore() =>
      Future.error(const PurchaseException(PurchaseFailure.unknown));
}
