import 'package:flutter/foundation.dart';

enum PlanPeriod { monthly, yearly, lifetime }

/// A Premium product as the store sells it. Prices are always the store's
/// own formatted strings, never hard-coded.
@immutable
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.period,
    required this.price,
    this.isMostPopular = false,
    this.badge,
  });

  /// The store's product id.
  final String id;
  final PlanPeriod period;

  /// Localized price from the store ("$29.00").
  final String price;

  /// Shows the "Most Popular" header.
  final bool isMostPopular;

  /// Corner badge ("-75%").
  final String? badge;
}

/// The current offer: the plans and, if any, when the discount ends.
@immutable
class PremiumOffering {
  const PremiumOffering({
    required this.plans,
    this.discountPercent,
    this.expiresAt,
  });

  final List<PremiumPlan> plans;

  /// "60 % off your upgrade".
  final int? discountPercent;
  final DateTime? expiresAt;
}

/// Why a purchase or restore did not go through.
enum PurchaseFailure { cancelled, nothingToRestore, unknown }

class PurchaseException implements Exception {
  const PurchaseException(this.failure);

  final PurchaseFailure failure;
}

/// Store access. A fake for now; RevenueCat in plan step 22.
abstract interface class PremiumRepository {
  Future<PremiumOffering> offering();

  /// Whether the user has Premium, re-emitted on changes.
  Stream<bool> watchIsPremium();

  /// Throws [PurchaseException].
  Future<void> purchase(PremiumPlan plan);

  /// Throws [PurchaseException].
  Future<void> restore();
}
