import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/features/design_system/presentation/design_system_page.dart';

/// Every route in the app. Navigate with `context.goNamed(AppRoute.x.name)`.
enum AppRoute {
  /// Temporary home until the splash screen is rebuilt (plan step 3).
  designSystem('/design-system')
  ;

  const AppRoute(this.path);

  final String path;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.designSystem.path,
    routes: [
      GoRoute(
        path: AppRoute.designSystem.path,
        name: AppRoute.designSystem.name,
        builder: (context, state) => const DesignSystemPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
