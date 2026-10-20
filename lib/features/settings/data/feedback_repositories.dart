import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Sends a message from Settings → Feedback.
typedef SendFeedback = Future<void> Function(String message);

/// Saves feedback at `users/{uid}/feedback/{id}`, so it is deleted with the
/// account. Read it in the Firebase console (a collection group query on
/// `feedback` lists everyone's).
SendFeedback firestoreFeedback({
  required String uid,
  FirebaseFirestore? firestore,
}) {
  final feedback = (firestore ?? FirebaseFirestore.instance)
      .collection('users')
      .doc(uid)
      .collection(feedbackCollection);
  return (message) async {
    final info = await PackageInfo.fromPlatform();
    // Like the habits, saved locally at once and synced when online.
    unawaited(
      feedback
          .add({
            'message': message,
            'createdAt': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
            'appVersion': '${info.version}+${info.buildNumber}',
          })
          .then<void>((_) {})
          .catchError((Object error) {
            debugPrint('Feedback write failed: $error');
          }),
    );
  };
}

/// The subcollection of feedback under each user, also used when deleting
/// the account.
const feedbackCollection = 'feedback';

/// The app's way to send feedback: logs it by default (tests); `main`
/// overrides it with [firestoreFeedback] for the signed-in user.
final sendFeedbackProvider = Provider<SendFeedback>(
  (ref) =>
      (message) async => debugPrint('Feedback: $message'),
);
