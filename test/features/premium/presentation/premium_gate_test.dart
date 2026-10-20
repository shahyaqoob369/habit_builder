import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/premium/presentation/premium_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  late SharedPreferencesWithCache preferences;

  setUp(() async {
    preferences = await createTestPreferences({
      PreferenceKeys.onboardingCompleted: true,
    });
  });

  testWidgets('a locked lesson opens the paywall', (tester) async {
    tester.useScreen(designSize);
    await tester.pumpFullApp(preferences);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('30 Day Journal Challenge').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('2.  Adopting Prompts to Your Day'));
    // The paywall's countdown ticks every second: pump, don't settle.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PremiumPage), findsOneWidget);
  });
}
