/// Every route in the app. Navigate with `context.goNamed(AppRoute.x.name)`.
enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),

  /// Developer preview of the design tokens. Also the temporary destination
  /// after onboarding until the auth screens exist (plan step 4).
  designSystem('/design-system')
  ;

  const AppRoute(this.path);

  final String path;
}
