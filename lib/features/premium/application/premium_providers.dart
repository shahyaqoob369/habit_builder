import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';

/// The plans on offer.
final FutureProvider<PremiumOffering> offeringProvider =
    FutureProvider<PremiumOffering>(
      (ref) => ref.watch(premiumRepositoryProvider).offering(),
    );

/// Whether the user has Premium.
final StreamProvider<bool> isPremiumProvider = StreamProvider<bool>(
  (ref) => ref.watch(premiumRepositoryProvider).watchIsPremium(),
);
