/// Every route in the app. Navigate with `context.goNamed(AppRoute.x.name)`.
///
/// [path] is absolute for top-level routes and relative for nested ones.
enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),
  login('/login'),

  /// Nested under [login], so Back returns to it.
  signUp('sign-up'),

  /// Nested under [login], so Back returns to it.
  resetPassword('reset-password'),

  /// Developer preview of the design tokens. Also the temporary destination
  /// after signing in, until the home screen exists (plan step 5).
  designSystem('/design-system')
  ;

  const AppRoute(this.path);

  final String path;
}
