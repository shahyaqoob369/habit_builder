import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/data/firestore_community_repository.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/data/firestore_habit_repository.dart';
import 'package:habit_builder/features/settings/data/feedback_repositories.dart';

/// Swaps the providers' in-memory fakes (used by tests and `FAKE_AUTH`)
/// for Firebase. Used by `main` and the integration tests.
List<Override> firebaseOverrides() => [
  authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
  habitRepositoryProvider.overrideWith((ref) {
    // Only a different user (not a renamed one) needs a new repository.
    final uid = ref.watch(authStateProvider.select((user) => user.value?.id));
    return uid == null
        ? const SignedOutHabitRepository()
        : FirestoreHabitRepository(uid: uid);
  }),
  communityRepositoryProvider.overrideWith((ref) {
    final uid = ref.watch(authStateProvider.select((user) => user.value?.id));
    return uid == null
        ? const SignedOutCommunityRepository()
        : FirestoreCommunityRepository(
            uid: uid,
            // Read when writing, so a rename shows on new posts at once.
            authorName: () =>
                FirebaseAuth.instance.currentUser?.displayName ?? '',
          );
  }),
  sendFeedbackProvider.overrideWith((ref) {
    final uid = ref.watch(authStateProvider.select((user) => user.value?.id));
    // Feedback is only sent from Settings, which needs a signed-in user.
    return uid == null
        ? (_) => Future.error(StateError('Not signed in'))
        : firestoreFeedback(uid: uid);
  }),
];
