import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';
import 'package:habit_builder/features/community/data/firestore_community_repository.dart';
import 'package:habit_builder/features/habits/data/firestore_habit_repository.dart';
import 'package:habit_builder/features/settings/data/feedback_repositories.dart';

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
    _write(
      _profile(user.uid).set({
        'name': name,
        'email': user.email,
        'marketingOptIn': details.marketingOptIn,
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
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

  @override
  Future<SocialSignIn> signInWithGoogle() => _guard(() async {
    final credential = await _googleCredential();
    return _socialSignIn(await _auth.signInWithCredential(credential));
  });

  @override
  Future<SocialSignIn> signInWithApple() => _guard(() async {
    // Firebase runs Apple's native sheet on iOS. Android would need a
    // Services ID and the web flow (later, with the Android release).
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw const AuthException(AuthFailure.unavailable);
    }
    return _socialSignIn(await _auth.signInWithProvider(_appleProvider()));
  });

  @override
  Future<void> signOut() => _guard(() async {
    await _auth.signOut();
    // So the next Google sign-in asks which account to use.
    if (_googleReady != null) {
      unawaited(GoogleSignIn.instance.signOut().catchError((Object _) {}));
    }
  });

  /// Started once per app run: Google Sign-In may be set up only once.
  static Future<void>? _googleReady;

  /// Shows Google's sign-in and returns its credential for Firebase. On
  /// iOS the client ID comes from `GoogleService-Info.plist`.
  static Future<OAuthCredential> _googleCredential() async {
    final google = GoogleSignIn.instance;
    await (_googleReady ??= google.initialize());
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthException(AuthFailure.cancelled);
      }
      debugPrint('Google sign-in failed: ${e.code} ${e.description}');
      throw const AuthException(AuthFailure.unknown);
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const AuthException(AuthFailure.unknown);
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  static AppleAuthProvider _appleProvider() => AppleAuthProvider()
    ..addScope('email')
    ..addScope('name');

  /// Creates the profile the first time a Google or Apple user signs in.
  /// Apple shares the name only on that first sign-in.
  SocialSignIn _socialSignIn(UserCredential credential) {
    final user = credential.user!;
    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
    if (isNewUser) {
      _write(
        _profile(user.uid).set({
          'name': (user.displayName ?? '').trim(),
          'email': user.email,
          'marketingOptIn': false,
          'createdAt': FieldValue.serverTimestamp(),
        }),
      );
    }
    return (user: _toAuthUser(user)!, isNewUser: isNewUser);
  }

  @override
  Future<void> deleteAccount({String? password}) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Firebase only deletes accounts that signed in recently, so confirm
    // with the password, or by signing in with Google or Apple again.
    // This also makes sure the profile is never deleted while the account
    // stays.
    final providers = {for (final p in user.providerData) p.providerId};
    String? appleCode;
    if (password != null && user.email != null) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
    } else if (providers.contains(AppleAuthProvider.PROVIDER_ID)) {
      final result = await user.reauthenticateWithProvider(_appleProvider());
      appleCode = result.additionalUserInfo?.authorizationCode;
    } else if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
      await user.reauthenticateWithCredential(await _googleCredential());
    }
    await FirestoreCommunityRepository.deleteUserContent(_firestore, user.uid);
    for (final collection in _userCollections) {
      await _deleteAll(_profile(user.uid).collection(collection));
    }
    await _profile(user.uid).delete();
    if (appleCode != null) await _revokeApple(appleCode);
    await user.delete();
  });

  @override
  Future<AuthUser> updateName(String name) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    await user.updateDisplayName(name);
    _write(
      _profile(user.uid).set({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
    await user.reload();
    return _toAuthUser(_auth.currentUser)!;
  });

  /// Apple requires apps to revoke Sign in with Apple when the account is
  /// deleted. Needs the Apple key in the Firebase console (FIREBASE.md);
  /// without it this fails, and the account is deleted anyway.
  Future<void> _revokeApple(String authorizationCode) async {
    try {
      await _auth.revokeTokenWithAuthorizationCode(authorizationCode);
    } on FirebaseAuthException catch (e) {
      debugPrint('Apple token revocation failed: ${e.code}');
    }
  }

  /// Saves to Firestore without waiting for the server, like the habits:
  /// the local copy updates at once and syncs when online.
  static void _write(Future<void> write) {
    unawaited(
      write.catchError((Object error) {
        debugPrint('Profile write failed: $error');
      }),
    );
  }

  /// Everything stored under `users/{uid}`, deleted with the account.
  /// Add each new per-user collection here.
  static const List<String> _userCollections = [
    FirestoreHabitRepository.collection,
    feedbackCollection,
    FirestoreCommunityRepository.blockedCollection,
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
    'account-exists-with-different-credential' ||
    'credential-already-in-use' => AuthFailure.differentSignInMethod,
    // Apple's sheet closed (FlutterFire's codes).
    'canceled' || 'web-context-canceled' => AuthFailure.cancelled,
    _ => AuthFailure.unknown,
  };
}
