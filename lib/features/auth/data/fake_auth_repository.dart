import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';

/// In-memory [AuthRepository] for tests and debug screenshots. Accounts
/// last until the app restarts.
///
/// One demo account is built in: [demoEmail] / [demoPassword].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.latency = const Duration(milliseconds: 800),
    bool signedIn = false,
  }) {
    if (signedIn) _currentUser = demoUser;
  }

  static const demoEmail = 'demo@example.com';
  static const demoPassword = 'habits123';
  static const demoUser = AuthUser(
    id: 'fake-0',
    email: demoEmail,
    name: 'Demo',
  );

  /// Simulated network time, so loading states can be seen.
  final Duration latency;

  final Map<String, ({String name, String password})> _accounts = {
    demoEmail: (name: 'Demo', password: demoPassword),
  };

  final _socialAccounts = <String>{};

  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;
  var _nextId = 1;

  @override
  AuthUser? get currentUser => _currentUser;

  void _setUser(AuthUser? user) {
    _currentUser = user;
    _changes.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    // New listeners get the current user first, like Firebase.
    late final StreamController<AuthUser?> controller;
    StreamSubscription<AuthUser?>? subscription;
    controller = StreamController<AuthUser?>(
      onListen: () {
        controller.add(_currentUser);
        subscription = _changes.stream.listen(controller.add);
      },
      // Don't return the cancel future: it completes in the root zone,
      // which widget tests never run, so `.first` would never finish.
      onCancel: () => unawaited(subscription?.cancel()),
    );
    return controller.stream;
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    final key = _normalize(email);
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    return _signIn(key, account.name);
  }

  @override
  Future<AuthUser> signUp(SignUpDetails details) async {
    await Future<void>.delayed(latency);
    final key = _normalize(details.email);
    if (_accounts.containsKey(key)) {
      throw const AuthException(AuthFailure.emailAlreadyInUse);
    }
    final name = details.name.trim();
    _accounts[key] = (name: name, password: details.password);
    return _signIn(key, name);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      Future<void>.delayed(latency);

  @override
  Future<SocialSignIn> signInWithGoogle() => _signInWithProvider('google');

  @override
  Future<SocialSignIn> signInWithApple() => _signInWithProvider('apple');

  @override
  Future<void> signOut() async => _setUser(null);

  @override
  Future<void> deleteAccount({String? password}) async {
    await Future<void>.delayed(latency);
    final user = _currentUser;
    if (user == null) return;
    if (user.hasPassword && _accounts[user.email]?.password != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    _accounts.remove(user.email);
    _socialAccounts.remove(user.email);
    _setUser(null);
  }

  @override
  Future<AuthUser> updateName(String name) async {
    final user = _currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    final account = _accounts[user.email];
    if (account != null) {
      _accounts[user.email] = (name: name, password: account.password);
    }
    final updated = user.copyWith(name: name);
    _setUser(updated);
    return updated;
  }

  Future<SocialSignIn> _signInWithProvider(String provider) async {
    await Future<void>.delayed(latency);
    final email = '$provider.user@example.com';
    final isNewUser = _socialAccounts.add(email);
    return (
      user: _signIn(email, null, hasPassword: false),
      isNewUser: isNewUser,
    );
  }

  AuthUser _signIn(String email, String? name, {bool hasPassword = true}) {
    final user = AuthUser(
      id: 'fake-${_nextId++}',
      email: email,
      name: name,
      hasPassword: hasPassword,
    );
    _setUser(user);
    return user;
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}

/// The app's [AuthRepository]. `main` overrides it with Firebase; the fake
/// is the default so tests never touch Firebase.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(),
);

/// The signed-in user (or null), kept up to date.
final StreamProvider<AuthUser?> authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
