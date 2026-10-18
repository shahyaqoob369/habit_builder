import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/features/design_system/presentation/design_system_page.dart';

void main() {
  group('App', () {
    testWidgets('starts on the design system preview', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemPage), findsOneWidget);
    });
  });
}
