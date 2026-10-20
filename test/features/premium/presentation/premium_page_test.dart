import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/core/config/app_config.dart';
import 'package:habit_builder/core/links/link_launcher.dart';
import 'package:habit_builder/features/community/application/community_providers.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:habit_builder/features/premium/presentation/premium_page.dart';
import 'package:habit_builder/features/premium/presentation/widgets/plan_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('PremiumPage', () {
    final now = DateTime(2026, 10, 20, 0, 3, 12);
    late FakePremiumRepository store;
    late List<Uri> opened;

    /// The paywall pushed over a home screen, so it can close itself.
    Future<void> pumpPaywall(WidgetTester tester) async {
      store = FakePremiumRepository(latency: Duration.zero, clock: () => now);
      opened = [];
      tester.useScreen(const Size(414, 1100));
      final router = GoRouter(
        initialLocation: '/premium',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('home')),
            routes: [
              GoRoute(
                path: 'premium',
                builder: (context, state) => const PremiumPage(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpApp(
        Router.withConfig(config: router),
        overrides: [
          premiumRepositoryProvider.overrideWithValue(store),
          clockProvider.overrideWithValue(() => now),
          openLinkProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
      );
      await tester.pump();
    }

    testWidgets(
      'shows the offer countdown, benefits and plans',
      (
        tester,
      ) async {
        await pumpPaywall(tester);

        expect(find.text('60% off your upgrade'), findsOneWidget);
        // Midnight minus 00:03:12.
        expect(find.text('23'), findsOneWidget);
        expect(find.text('56'), findsOneWidget);
        expect(find.text('48'), findsOneWidget);
        expect(find.text('Unlimited habits'), findsOneWidget);
        expect(find.text(r'$29.00'), findsOneWidget);
        expect(find.text('Most Popular'), findsOneWidget);
        expect(
          find.text('Secured with the App Store. Cancel anytime'),
          findsOneWidget,
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('Yearly is chosen first; tapping a plan chooses it', (
      tester,
    ) async {
      await pumpPaywall(tester);
      PlanCard card(String id) => tester.widget<PlanCard>(
        find.byWidgetPredicate((w) => w is PlanCard && w.plan.id == id),
      );

      expect(card('yearly').selected, isTrue);
      await tester.tap(find.text('Lifetime'));
      await tester.pump();
      expect(card('lifetime').selected, isTrue);
      expect(card('yearly').selected, isFalse);
    });

    testWidgets('subscribing unlocks Premium and closes the paywall', (
      tester,
    ) async {
      await pumpPaywall(tester);

      await tester.tap(find.text('Subscribe Now'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // The countdown ticks every second, so the page never settles.
      expect(find.text('Welcome to Premium!'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('restore with nothing bought says so', (tester) async {
      await pumpPaywall(tester);

      await tester.tap(find.text('Restore Purchase'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('No purchase to restore on this account.'),
        findsOneWidget,
      );
      expect(find.byType(PremiumPage), findsOneWidget);
    });

    testWidgets('terms and privacy links open', (tester) async {
      await pumpPaywall(tester);

      await tester.tap(find.text('Terms of Service'));
      await tester.tap(find.text('Privacy Policy'));
      await tester.pump();

      expect(opened, [
        Uri.parse(AppConfig.termsUrl),
        Uri.parse(AppConfig.privacyPolicyUrl),
      ]);
    });
  });
}
