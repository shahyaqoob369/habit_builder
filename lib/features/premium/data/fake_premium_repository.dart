import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';

/// Sample store with the design's three plans; purchases always succeed and
/// last until the app restarts. For tests; the app uses RevenueCat.
class FakePremiumRepository implements PremiumRepository {
  FakePremiumRepository({
    this.latency = const Duration(milliseconds: 800),
    DateTime Function()? clock,
    bool premium = false,
  }) : _clock = clock ?? DateTime.now,
       _premium = premium,
       _everPurchased = premium;

  final Duration latency;
  final DateTime Function() _clock;
  bool _premium;
  bool _everPurchased;
  final _changes = StreamController<bool>.broadcast();

  @override
  Future<PremiumOffering> offering() async {
    final now = _clock();
    return PremiumOffering(
      discountPercent: 60,
      // The sample offer ends at midnight.
      expiresAt: DateTime(now.year, now.month, now.day + 1),
      plans: const [
        PremiumPlan(
          id: 'monthly',
          period: PlanPeriod.monthly,
          price: r'$19.00',
        ),
        PremiumPlan(
          id: 'yearly',
          period: PlanPeriod.yearly,
          price: r'$29.00',
          isMostPopular: true,
        ),
        PremiumPlan(
          id: 'lifetime',
          period: PlanPeriod.lifetime,
          price: r'$49.00',
          badge: '-75%',
        ),
      ],
    );
  }

  @override
  Stream<bool> watchIsPremium() {
    StreamSubscription<bool>? changes;
    late final StreamController<bool> controller;
    controller = StreamController<bool>(
      onListen: () {
        controller.add(_premium);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  @override
  Future<void> purchase(PremiumPlan plan) async {
    await Future<void>.delayed(latency);
    _everPurchased = true;
    _set(premium: true);
  }

  @override
  Future<void> restore() async {
    await Future<void>.delayed(latency);
    if (!_everPurchased) {
      throw const PurchaseException(PurchaseFailure.nothingToRestore);
    }
    _set(premium: true);
  }

  void _set({required bool premium}) {
    _premium = premium;
    _changes.add(premium);
  }
}

final premiumRepositoryProvider = Provider<PremiumRepository>(
  (ref) => FakePremiumRepository(),
);
