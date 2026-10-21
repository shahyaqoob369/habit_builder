import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/features/community/domain/community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';

/// [CommunityRepository] on Firestore (see `firestore.rules`):
///
/// ```text
/// posts/{postId}                    authorId, authorName, text, createdAt,
///                                   likeCount, commentCount
/// posts/{postId}/likes/{uid}        uid, createdAt
/// posts/{postId}/comments/{id}      authorId, authorName, text, createdAt
/// reports/{id}                      postId, reporterId, createdAt
/// users/{uid}/blocked/{memberId}    createdAt
/// ```
///
/// Without Cloud Functions (Spark plan), each like or comment updates its
/// post's counter in the same batch, and the rules check that the counter
/// moves by exactly one together with it. Writes don't wait for the
/// server, like the habits.
class FirestoreCommunityRepository implements CommunityRepository {
  FirestoreCommunityRepository({
    required this.uid,
    required this.authorName,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// The signed-in user.
  final String uid;

  /// The name shown on new posts and comments.
  final String Function() authorName;

  final FirebaseFirestore _firestore;

  /// Posts in the feed (newest first).
  static const feedSize = 100;

  CollectionReference<Map<String, Object?>> get _posts =>
      _firestore.collection('posts');

  CollectionReference<Map<String, Object?>> get _blocked =>
      _firestore.collection('users').doc(uid).collection(blockedCollection);

  /// Under `users/{uid}`, deleted with the account.
  static const blockedCollection = 'blocked';

  Stream<Set<String>> _blockedIds() =>
      _blocked.snapshots().map((s) => {for (final d in s.docs) d.id});

  Stream<Set<String>> _likedPostIds() => _firestore
      .collectionGroup('likes')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((s) => {for (final d in s.docs) d.reference.parent.parent!.id});

  @override
  Stream<List<Post>> watchPosts() {
    final posts = _posts
        .orderBy('createdAt', descending: true)
        .limit(feedSize)
        .snapshots();
    return _combine3(posts, _likedPostIds(), _blockedIds(), (
      snapshot,
      liked,
      blocked,
    ) {
      return [
        for (final doc in snapshot.docs)
          if (!blocked.contains(doc.data()['authorId']))
            _toPost(doc, likedByMe: liked.contains(doc.id)),
      ];
    });
  }

  @override
  Stream<List<Comment>> watchComments(String postId) {
    final comments = _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots();
    return _combine2(comments, _blockedIds(), (snapshot, blocked) {
      return [
        for (final doc in snapshot.docs)
          if (!blocked.contains(doc.data()['authorId']))
            Comment(
              id: doc.id,
              author: _member(doc.data()),
              text: doc.data()['text'] as String? ?? '',
              createdAt: _time(doc.data()['createdAt']),
            ),
      ];
    });
  }

  @override
  Future<void> addPost(String text) async => _write(
    _posts.add({
      'authorId': uid,
      'authorName': authorName(),
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'commentCount': 0,
    }),
  );

  @override
  Future<void> deletePost(String postId) =>
      _deletePostWithContent(_posts.doc(postId));

  @override
  Future<void> toggleLike(String postId) async {
    final post = _posts.doc(postId);
    final like = post.collection('likes').doc(uid);
    final liked = (await like.get()).exists;
    final batch = _firestore.batch();
    if (liked) {
      batch
        ..delete(like)
        ..update(post, {'likeCount': FieldValue.increment(-1)});
    } else {
      batch
        ..set(like, {'uid': uid, 'createdAt': FieldValue.serverTimestamp()})
        ..update(post, {'likeCount': FieldValue.increment(1)});
    }
    _write(batch.commit());
  }

  @override
  Future<void> addComment(String postId, String text) async {
    final post = _posts.doc(postId);
    final comment = post.collection('comments').doc();
    final batch = _firestore.batch()
      ..set(comment, {
        'authorId': uid,
        'authorName': authorName(),
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(post, {
        'commentCount': FieldValue.increment(1),
        'lastCommentId': comment.id,
      });
    _write(batch.commit());
  }

  @override
  Future<void> reportPost(String postId) async => _write(
    _firestore.collection('reports').add({
      'postId': postId,
      'reporterId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> blockMember(String memberId) async => _write(
    _blocked.doc(memberId).set({'createdAt': FieldValue.serverTimestamp()}),
  );

  /// Removes everything [uid] wrote in the community: their likes and
  /// comments on other posts (with the counters), and their own posts.
  /// Part of deleting the account; their block list goes with
  /// `users/{uid}`.
  static Future<void> deleteUserContent(
    FirebaseFirestore firestore,
    String uid,
  ) async {
    final likes = await firestore
        .collectionGroup('likes')
        .where('uid', isEqualTo: uid)
        .get();
    for (final like in likes.docs) {
      final post = like.reference.parent.parent!;
      await (firestore.batch()
            ..delete(like.reference)
            ..update(post, {'likeCount': FieldValue.increment(-1)}))
          .commit();
    }
    final comments = await firestore
        .collectionGroup('comments')
        .where('authorId', isEqualTo: uid)
        .get();
    for (final comment in comments.docs) {
      final post = comment.reference.parent.parent!;
      await (firestore.batch()
            ..delete(comment.reference)
            ..update(post, {
              'commentCount': FieldValue.increment(-1),
              'lastRemovedCommentId': comment.id,
            }))
          .commit();
    }
    final posts = await firestore
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .get();
    for (final post in posts.docs) {
      await _deletePostWithContent(post.reference);
    }
  }

  /// Deletes a post's likes and comments (its author may), then the post.
  static Future<void> _deletePostWithContent(
    DocumentReference<Map<String, Object?>> post,
  ) async {
    for (final sub in ['likes', 'comments']) {
      final docs = (await post.collection(sub).get()).docs;
      // Batches hold at most 500 writes.
      for (var i = 0; i < docs.length; i += 400) {
        final batch = post.firestore.batch();
        for (final doc in docs.skip(i).take(400)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await post.delete();
  }

  Post _toPost(
    QueryDocumentSnapshot<Map<String, Object?>> doc, {
    required bool likedByMe,
  }) {
    final data = doc.data();
    return Post(
      id: doc.id,
      author: _member(data),
      text: data['text'] as String? ?? '',
      createdAt: _time(data['createdAt']),
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      likedByMe: likedByMe,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      isMine: data['authorId'] == uid,
    );
  }

  static Member _member(Map<String, Object?> data) => Member(
    id: data['authorId'] as String? ?? '',
    name: data['authorName'] as String? ?? '',
    // One illustrated avatar for everyone until avatars are chosen.
    avatar: AppImages.avatar,
  );

  /// A server time; null while a new write hasn't reached the server.
  static DateTime _time(Object? value) =>
      value is Timestamp ? value.toDate() : DateTime.now();

  static void _write(Future<void> write) {
    unawaited(
      write.catchError((Object error) {
        debugPrint('Community write failed: $error');
      }),
    );
  }
}

/// The latest values of two streams, combined, once both have one.
Stream<R> _combine2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A, B) combine,
) => _combineAll([a, b], (values) => combine(values[0] as A, values[1] as B));

/// The latest values of three streams, combined, once all have one.
Stream<R> _combine3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A, B, C) combine,
) => _combineAll(
  [a, b, c],
  (values) => combine(values[0] as A, values[1] as B, values[2] as C),
);

Stream<R> _combineAll<R>(
  List<Stream<Object?>> streams,
  R Function(List<Object?>) combine,
) {
  late final StreamController<R> controller;
  final values = List<Object?>.filled(streams.length, null);
  final has = List<bool>.filled(streams.length, false);
  final subscriptions = <StreamSubscription<Object?>>[];
  controller = StreamController<R>(
    onListen: () {
      for (var i = 0; i < streams.length; i++) {
        subscriptions.add(
          streams[i].listen(
            (value) {
              values[i] = value;
              has[i] = true;
              if (has.every((h) => h)) controller.add(combine(values));
            },
            onError: controller.addError,
          ),
        );
      }
    },
    onCancel: () async {
      for (final s in subscriptions) {
        await s.cancel();
      }
    },
  );
  return controller.stream;
}

/// Used while nobody is signed in: an empty feed, and nothing can be saved.
class SignedOutCommunityRepository implements CommunityRepository {
  const SignedOutCommunityRepository();

  @override
  Stream<List<Post>> watchPosts() => Stream.value(const []);

  @override
  Stream<List<Comment>> watchComments(String postId) => Stream.value(const []);

  @override
  Future<void> addPost(String text) => _signedOut();

  @override
  Future<void> deletePost(String postId) => _signedOut();

  @override
  Future<void> toggleLike(String postId) => _signedOut();

  @override
  Future<void> addComment(String postId, String text) => _signedOut();

  @override
  Future<void> reportPost(String postId) => _signedOut();

  @override
  Future<void> blockMember(String memberId) => _signedOut();

  static Future<void> _signedOut() => Future.error(StateError('Not signed in'));
}
