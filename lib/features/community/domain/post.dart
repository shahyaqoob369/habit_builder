import 'package:flutter/foundation.dart';

/// Someone who posts or comments.
@immutable
class Member {
  const Member({required this.id, required this.name, required this.avatar});

  final String id;
  final String name;

  /// Avatar image: an asset path for the samples, later a URL.
  final String avatar;
}

@immutable
class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final Member author;
  final String text;
  final DateTime createdAt;
}

/// A community post (Figma "Post").
@immutable
class Post {
  const Post({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
    this.commentCount = 0,
    this.isMine = false,
  });

  final String id;
  final Member author;
  final String text;
  final DateTime createdAt;

  /// Likes from everyone, including mine.
  final int likeCount;
  final bool likedByMe;

  /// Comments are loaded per post (`watchComments`); the feed shows the
  /// count.
  final int commentCount;

  /// Written by the signed-in user (who may delete it).
  final bool isMine;

  Post copyWith({int? likeCount, bool? likedByMe, int? commentCount}) {
    return Post(
      id: id,
      author: author,
      text: text,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      commentCount: commentCount ?? this.commentCount,
      isMine: isMine,
    );
  }
}
