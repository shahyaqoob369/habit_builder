import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/reset_password_page.dart';
import 'package:habit_builder/features/auth/presentation/sign_up_page.dart';
import 'package:habit_builder/features/design_system/presentation/design_system_page.dart';
import 'package:habit_builder/features/onboarding/presentation/onboarding_page.dart';
import 'package:habit_builder/features/splash/presentation/splash_page.dart';

export 'package:habit_builder/app/router/app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.splash.path,
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
