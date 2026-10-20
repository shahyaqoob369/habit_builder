import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';

/// In-memory [AuthRepository] with sample data, used until the Firebase one
/// exists (plan step 15). Accounts last until the app restarts.
///
/// One demo account is built in: [demoEmail] / [demoPassword].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.latency = const Duration(milliseconds: 800)});

  static const demoEmail = 'demo@example.com';
  static const demoPassword = 'habits123';

  /// Simulated network time, so loading states can be seen.
  final Duration latency;

  final Map<String, ({String name, String password})> _accounts = {
    demoEmail: (name: 'Demo', password: demoPassword),
  };

  AuthUser? _currentUser;
  var _nextId = 1;

  @override
  AuthUser? get currentUser => _currentUser;

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
  Future<AuthUser> signInWithGoogle() => _signInWithProvider('google');

  @override
  Future<AuthUser> signInWithFacebook() => _signInWithProvider('facebook');

  @override
  Future<void> signOut() async => _currentUser = null;

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(latency);
    final user = _currentUser;
    if (user != null) _accounts.remove(user.email);
    _currentUser = null;
  }

  @override
  Future<AuthUser> updateName(String name) async {
    final user = _currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    final account = _accounts[user.email];
    if (account != null) {
      _accounts[user.email] = (name: name, password: account.password);
    }
    return _currentUser = AuthUser(id: user.id, email: user.email, name: name);
  }

  Future<AuthUser> _signInWithProvider(String provider) async {
    await Future<void>.delayed(latency);
    return _signIn('$provider.user@example.com', null);
  }

  AuthUser _signIn(String email, String? name) {
    return _currentUser = AuthUser(
      id: 'fake-${_nextId++}',
      email: email,
      name: name,
    );
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}

/// The app's [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(),
);
