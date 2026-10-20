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
    this.comments = const [],
  });

  final String id;
  final Member author;
  final String text;
  final DateTime createdAt;

  /// Likes from everyone, including mine.
  final int likeCount;
  final bool likedByMe;

  /// Oldest first.
  final List<Comment> comments;

  Post copyWith({
    int? likeCount,
    bool? likedByMe,
    List<Comment>? comments,
  }) {
    return Post(
      id: id,
      author: author,
      text: text,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      comments: comments ?? this.comments,
    );
  }
}
