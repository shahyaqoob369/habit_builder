import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/config/app_config.dart';
import 'package:habit_builder/core/links/link_launcher.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/settings/data/feedback_repositories.dart';
import 'package:habit_builder/features/settings/data/settings_repository.dart';
import 'package:habit_builder/features/settings/presentation/notification_settings_page.dart';
import 'package:habit_builder/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  late SharedPreferencesWithCache preferences;
  late List<Uri> opened;
  late RecordingAnalytics analytics;
  late List<String> feedback;

  setUp(() async {
    preferences = await createTestPreferences();
    opened = [];
    analytics = RecordingAnalytics();
    feedback = [];
  });

  Future<void> pump(WidgetTester tester, Widget page, {bool canOpen = true}) {
    tester.useScreen(designSize);
    return tester.pumpApp(
      page,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        analyticsProvider.overrideWithValue(analytics),
        sendFeedbackProvider.overrideWithValue((message) async {
          feedback.add(message);
        }),
        openLinkProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return canOpen;
        }),
      ],
    );
  }

  group('SettingsPage', () {
    testWidgets('shows the profile card, General and Support', (
      tester,
    ) async {
      await pump(tester, const SettingsPage());

      expect(find.text('Check Your Profile'), findsOneWidget);
      for (final row in [
        'Notifications',
        'More customization',
        'Contact',
        'Feedback',
        'Privacy Policy',
        'About',
      ]) {
        expect(find.text(row), findsOneWidget);
      }
    });

    testWidgets('Contact emails support; Privacy opens the policy', (
      tester,
    ) async {
      await pump(tester, const SettingsPage());

      await tester.tap(find.text('Contact'));
      await tester.tap(find.text('Privacy Policy'));
      await tester.pump();

      expect(opened, [
        Uri(scheme: 'mailto', path: AppConfig.supportEmail),
        Uri.parse(AppConfig.privacyPolicyUrl),
      ]);
    });

    testWidgets('says so when a link cannot open', (tester) async {
      await pump(tester, const SettingsPage(), canOpen: false);

      await tester.tap(find.text('Privacy Policy'));
      await tester.pump();

      expect(
        find.text('Couldn’t open ${AppConfig.privacyPolicyUrl}'),
        findsOneWidget,
      );
    });

    testWidgets('feedback is sent and thanked', (tester) async {
      await pump(tester, const SettingsPage());

      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Love the teepee');
      await tester.pump();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Thanks for your feedback!'), findsOneWidget);
      expect(feedback, ['Love the teepee']);
    });
  });

  group('ToggleSettingsPage', () {
    testWidgets('notification switches are saved', (tester) async {
      await pump(tester, const ToggleSettingsPage.notifications());

      await tester.tap(find.text('Habit reminders'));
      await tester.pump();

      expect(preferences.getBool(PreferenceKeys.habitReminders), isFalse);
    });

    testWidgets('the daily quote can be hidden', (tester) async {
      await pump(tester, const ToggleSettingsPage.customize());

      await tester.tap(find.text('Daily quote'));
      await tester.pump();

      expect(preferences.getBool(PreferenceKeys.showQuote), isFalse);
      expect(const AppSettings().showQuote, isTrue);
    });

    testWidgets('sharing usage data can be turned off', (tester) async {
      await pump(tester, const ToggleSettingsPage.customize());

      await tester.tap(find.text('Share usage data'));
      await tester.pump();

      expect(preferences.getBool(PreferenceKeys.shareUsageData), isFalse);
      expect(analytics.collectionEnabled, isFalse);
      expect(const AppSettings().shareUsageData, isTrue);
    });
  });
}
