import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/features/community/domain/community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';

/// In-memory [CommunityRepository] with the design's four posts. Used until
/// the community backend (plan step 24).
class FakeCommunityRepository implements CommunityRepository {
  FakeCommunityRepository({DateTime? now})
    : _now = now ?? DateTime.now(),
      _posts = _samples(now ?? DateTime.now());

  /// The signed-in user, as a member.
  static const me = Member(id: 'me', name: 'You', avatar: AppImages.avatar);

  final DateTime _now;
  List<Post> _posts;
  final Set<String> _blocked = {};

  /// Posts reported by this user, for tests.
  @visibleForTesting
  final Set<String> reported = {};

  final _changes = StreamController<List<Post>>.broadcast();
  var _nextId = 100;

  List<Post> get _visible => List.unmodifiable([
    for (final post in _posts)
      if (!_blocked.contains(post.author.id))
        post.copyWith(
          comments: [
            for (final c in post.comments)
              if (!_blocked.contains(c.author.id)) c,
          ],
        ),
  ]);

  @override
  Stream<List<Post>> watchPosts() {
    StreamSubscription<List<Post>>? changes;
    late final StreamController<List<Post>> controller;
    controller = StreamController<List<Post>>(
      onListen: () {
        controller.add(_visible);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  void _update(String postId, Post Function(Post) change) {
    _posts = [for (final p in _posts) p.id == postId ? change(p) : p];
    _changes.add(_visible);
  }

  @override
  Future<void> addPost(String text) async {
    _posts = [
      Post(
        id: 'post-${_nextId++}',
        author: me,
        text: text.trim(),
        createdAt: _now,
      ),
      ..._posts,
    ];
    _changes.add(_visible);
  }

  @override
  Future<void> toggleLike(String postId) async => _update(
    postId,
    (p) => p.copyWith(
      likedByMe: !p.likedByMe,
      likeCount: p.likeCount + (p.likedByMe ? -1 : 1),
    ),
  );

  @override
  Future<void> addComment(String postId, String text) async => _update(
    postId,
    (p) => p.copyWith(
      comments: [
        ...p.comments,
        Comment(
          id: 'comment-${_nextId++}',
          author: me,
          text: text.trim(),
          createdAt: _now,
        ),
      ],
    ),
  );

  @override
  Future<void> reportPost(String postId) async => reported.add(postId);

  @override
  Future<void> blockMember(String memberId) async {
    _blocked.add(memberId);
    _changes.add(_visible);
  }

  static List<Post> _samples(DateTime now) {
    const jerome = Member(
      id: 'jerome',
      name: 'Jerome',
      avatar: 'assets/img/community/member_1.webp',
    );
    const gretchen = Member(
      id: 'gretchen',
      name: 'Gretchen',
      avatar: 'assets/img/community/member_3.webp',
    );
    const al = Member(
      id: 'al',
      name: 'Al',
      avatar: 'assets/img/community/member_2.webp',
    );
    const colin = Member(
      id: 'colin',
      name: 'Colin',
      avatar: 'assets/img/community/member_4.webp',
    );
    final ago = now.subtract(const Duration(minutes: 41));
    Comment comment(String id, Member author, String text, int minutes) =>
        Comment(
          id: id,
          author: author,
          text: text,
          createdAt: now.subtract(Duration(minutes: minutes)),
        );
    return [
      Post(
        id: 'post-1',
        author: jerome,
        createdAt: ago,
        likeCount: 3100,
        likedByMe: true,
        text:
            "Man, you're my new guru! Viewing the lessons for a second time. "
            'Thoroughly pleased. And impressed that you draw from scientific '
            'literature in telling memorable stories that make the ideas '
            'stick.',
        comments: [
          comment('c-1', gretchen, 'Same here, the second pass is gold.', 30),
          comment('c-2', al, 'Which lesson did you like most?', 12),
        ],
      ),
      Post(
        id: 'post-2',
        author: gretchen,
        createdAt: ago,
        likeCount: 3100,
        likedByMe: true,
        text:
            "I loved the course! I've been trying to break all this great "
            'stuff down into manageable chunks to help my clients develop '
            'healthy habits and achieve their personal goals.',
      ),
      Post(
        id: 'post-3',
        author: al,
        createdAt: ago,
        likeCount: 3100,
        likedByMe: true,
        text:
            'This course contains the most complete material on habit '
            "formation that I've seen. There is just enough theory to explain "
            'the principles, and not so much that it gets in the way.',
      ),
      Post(
        id: 'post-4',
        author: colin,
        createdAt: ago,
        likeCount: 3100,
        likedByMe: true,
        text:
            'The Habit Academy course has tremendously changed my life for '
            'the better! Having been a self improvement aficionado '
            'for decades, this one finally made the ideas stick.',
      ),
    ];
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => FakeCommunityRepository(),
);
