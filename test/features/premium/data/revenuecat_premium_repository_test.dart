import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/premium/data/revenuecat_premium_repository.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('premiumOfferingFrom', () {
    final now = DateTime(2026, 10, 30, 12);
    const context = PresentedOfferingContext('default', null, null);

    Package package(String id, PackageType type, String price) => Package(
      id,
      type,
      StoreProduct('premium_$id', '', '', 0, price, 'USD'),
      context,
    );

    Offering offering(Map<String, Object> metadata) => Offering(
      'default',
      'Default',
      metadata,
      [
        package(r'$rc_monthly', PackageType.monthly, r'$19.00'),
        package(r'$rc_annual', PackageType.annual, r'$29.00'),
        package(r'$rc_lifetime', PackageType.lifetime, r'$49.00'),
        package('extra', PackageType.custom, r'$1.00'),
      ],
    );

    PremiumOffering from(
      Map<String, Object> metadata, {
      DateTime? seenAt,
    }) => premiumOfferingFrom(
      offering(metadata),
      offerSeenAt: (now) => seenAt ?? now,
      now: now,
    );

    test('shows the store prices of the three plans, in order', () {
      final plans = from({}).plans;

      expect(plans.map((p) => p.period), PlanPeriod.values);
      expect(plans.map((p) => p.price), [r'$19.00', r'$29.00', r'$49.00']);
      expect(plans.first.id, r'$rc_monthly');
    });

    test('takes "Most Popular" and the badges from the metadata', () {
      final plans = from({
        'most_popular': r'$rc_annual',
        'badges': {r'$rc_lifetime': '-75%'},
      }).plans;

      expect(plans.map((p) => p.isMostPopular), [false, true, false]);
      expect(plans.map((p) => p.badge), [null, null, '-75%']);
    });

    test('has no countdown unless the metadata sets an offer', () {
      final offer = from({});

      expect(offer.discountPercent, isNull);
      expect(offer.expiresAt, isNull);
    });

    test('runs the offer for 24 hours from when it was first seen', () {
      final seenAt = now.subtract(const Duration(hours: 3));
      final offer = from({'offer_percent': 60}, seenAt: seenAt);

      expect(offer.discountPercent, 60);
      expect(offer.expiresAt, seenAt.add(offerDuration));
    });

    test('hides the offer once it has ended', () {
      final offer = from(
        {'offer_percent': 60},
        seenAt: now.subtract(const Duration(hours: 25)),
      );

      expect(offer.discountPercent, isNull);
      expect(offer.expiresAt, isNull);
    });
  });
}
