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

  // The four tabs of the signed-in shell, each with its own stack.
  home('/home'),

  /// Nested under [home].
  newHabit('new-habit'),

  /// Nested under [home]: `/home/habit/:id`.
  habitDetail('habit/:id'),

  /// Nested under [habitDetail].
  editHabit('edit'),
  courses('/courses'),

  /// Nested under [courses]: `/courses/course/:id`.
  courseDetail('course/:id'),
  community('/community'),

  /// Nested under [community]: `/community/post/:id`.
  postDetail('post/:id'),
  settings('/settings'),

  /// Developer preview of the design tokens (side menu, debug builds).
  designSystem('/design-system')
  ;

  const AppRoute(this.path);

  final String path;
}
