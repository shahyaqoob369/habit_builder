import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';
import 'package:habit_builder/features/habits/data/firestore_habit_repository.dart';

/// [AuthRepository] backed by Firebase Auth, with each user's profile in
/// Firestore at `users/{uid}` (see `firestore.rules`).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, Object?>> _profile(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() =>
      // userChanges also fires when the display name changes.
      _auth.userChanges().map(_toAuthUser);

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAuthUser(credential.user)!;
  });

  @override
  Future<AuthUser> signUp(SignUpDetails details) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: details.email,
      password: details.password,
    );
    final user = credential.user!;
    final name = details.name.trim();
    await user.updateDisplayName(name);
    await _profile(user.uid).set({
      'name': name,
      'email': user.email,
      'marketingOptIn': details.marketingOptIn,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // updateDisplayName doesn't refresh the cached user on every platform.
    await user.reload();
    return _toAuthUser(_auth.currentUser)!;
  });

  @override
  Future<void> sendPasswordResetEmail(String email) => _guard(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Same answer whether or not the email has an account.
      if (e.code != 'user-not-found' && e.code != 'invalid-email') rethrow;
    }
  });

  // Connected in plan steps 16 (Google, Apple) and 17 (Facebook).
  @override
  Future<AuthUser> signInWithGoogle() =>
      Future.error(const AuthException(AuthFailure.unavailable));

  @override
  Future<AuthUser> signInWithFacebook() =>
      Future.error(const AuthException(AuthFailure.unavailable));

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<void> deleteAccount({String? password}) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Firebase only deletes accounts that signed in recently, so confirm
    // the password first. This also makes sure the profile is never
    // deleted while the account stays.
    if (password != null && user.email != null) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
    }
    for (final collection in _userCollections) {
      await _deleteAll(_profile(user.uid).collection(collection));
    }
    await _profile(user.uid).delete();
    await user.delete();
  });

  @override
  Future<AuthUser> updateName(String name) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    await user.updateDisplayName(name);
    await _profile(user.uid).set({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.reload();
    return _toAuthUser(_auth.currentUser)!;
  });

  /// Everything stored under `users/{uid}`, deleted with the account.
  /// Add each new per-user collection here.
  static const List<String> _userCollections = [
    FirestoreHabitRepository.collection,
  ];

  static Future<void> _deleteAll(
    CollectionReference<Map<String, Object?>> collection,
  ) async {
    // Batches hold at most 500 writes.
    while (true) {
      final page = await collection.limit(400).get();
      if (page.docs.isEmpty) return;
      final batch = collection.firestore.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      hasPassword: user.providerData.any((p) => p.providerId == 'password'),
    );
  }

  /// Turns Firebase errors into [AuthException]s.
  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(failureFor(e.code));
    } on FirebaseException catch (e) {
      throw AuthException(
        e.code == 'unavailable' ? AuthFailure.network : AuthFailure.unknown,
      );
    }
  }

  /// The [AuthFailure] for a Firebase Auth error code.
  static AuthFailure failureFor(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' ||
    'user-disabled' => AuthFailure.invalidCredentials,
    'email-already-in-use' => AuthFailure.emailAlreadyInUse,
    'network-request-failed' => AuthFailure.network,
    'too-many-requests' => AuthFailure.tooManyAttempts,
    'requires-recent-login' => AuthFailure.requiresRecentLogin,
    'operation-not-allowed' => AuthFailure.unavailable,
    _ => AuthFailure.unknown,
  };
}
