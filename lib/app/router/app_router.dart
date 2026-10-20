import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/reset_password_page.dart';
import 'package:habit_builder/features/auth/presentation/sign_up_page.dart';
import 'package:habit_builder/features/community/presentation/community_page.dart';
import 'package:habit_builder/features/courses/presentation/courses_page.dart';
import 'package:habit_builder/features/design_system/presentation/design_system_page.dart';
import 'package:habit_builder/features/habits/presentation/new_habit_page.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:habit_builder/features/onboarding/presentation/onboarding_page.dart';
import 'package:habit_builder/features/settings/presentation/settings_page.dart';
import 'package:habit_builder/features/shell/presentation/app_shell.dart';
import 'package:habit_builder/features/splash/presentation/splash_page.dart';

export 'package:habit_builder/app/router/app_route.dart';

/// Debug builds can start on any screen, which helps check screens on a
/// simulator: `flutter run --dart-define=INITIAL_ROUTE=/home`.
const _debugInitialRoute = String.fromEnvironment('INITIAL_ROUTE');

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: kDebugMode && _debugInitialRoute.isNotEmpty
        ? _debugInitialRoute
        : AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: AppRoute.signUp.path,
            name: AppRoute.signUp.name,
            builder: (context, state) => const SignUpPage(),
          ),
          GoRoute(
            path: AppRoute.resetPassword.path,
            name: AppRoute.resetPassword.name,
            builder: (context, state) => const ResetPasswordPage(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: AppRoute.newHabit.path,
                    name: AppRoute.newHabit.name,
                    builder: (context, state) => const NewHabitPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.courses.path,
                name: AppRoute.courses.name,
                builder: (context, state) => const CoursesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.community.path,
                name: AppRoute.community.name,
                builder: (context, state) => const CommunityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings.path,
                name: AppRoute.settings.name,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
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
