import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/share/share_service.dart';
import 'package:habit_builder/features/community/application/community_providers.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/presentation/community_page.dart';
import 'package:habit_builder/features/community/presentation/post_detail_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);

  group('CommunityPage', () {
    late FakeCommunityRepository repository;
    late List<String> shared;

    Future<void> pumpPage(WidgetTester tester, Widget page) async {
      repository = FakeCommunityRepository(now: now);
      shared = [];
      tester.useScreen(const Size(414, 1100));
      await tester.pumpApp(
        page,
        overrides: [
          communityRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(() => now),
          shareTextProvider.overrideWithValue(
            (text, {origin}) async => shared.add(text),
          ),
        ],
      );
      await tester.pump();
    }

    testWidgets('shows the feed with names, times and counts', (tester) async {
      await pumpPage(tester, const CommunityPage());

      expect(find.text('Jerome'), findsOneWidget);
      expect(find.text('41m ago'), findsNWidgets(4));
      expect(find.bySemanticsLabel('Unlike, 3.1k'), findsNWidgets(4));
    });

    testWidgets('liking updates the count', (tester) async {
      await pumpPage(tester, const CommunityPage());

      await tester.tap(find.bySemanticsLabel('Unlike, 3.1k').first);
      await tester.pump();

      expect(find.bySemanticsLabel('Like, 3.1k'), findsOneWidget);
    });

    testWidgets('share opens the share sheet with the post', (tester) async {
      await pumpPage(tester, const CommunityPage());

      await tester.tap(find.bySemanticsLabel('Share').first);
      await tester.pump();

      expect(shared.single, startsWith('Jerome on Monumental Habits: Man,'));
    });

    testWidgets('long press lets you hide an author', (tester) async {
      await pumpPage(tester, const CommunityPage());

      await tester.longPress(find.text('Gretchen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide posts from Gretchen'));
      await tester.pumpAndSettle();

      expect(find.text('Gretchen'), findsNothing);
      expect(
        find.text('You won’t see posts from Gretchen anymore.'),
        findsOneWidget,
      );
    });

    testWidgets('the composer adds a post on top', (tester) async {
      await pumpPage(tester, const CommunityPage());

      await tester.tap(find.text('Share your progress…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Day 7 done!');
      await tester.pump();
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(find.text('Day 7 done!'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('a post shows its comments and takes new ones', (
      tester,
    ) async {
      await pumpPage(tester, const PostDetailPage(postId: 'post-1'));

      expect(find.text('Same here, the second pass is gold.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Great post');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();

      expect(find.text('Great post'), findsOneWidget);
    });
  });
}
