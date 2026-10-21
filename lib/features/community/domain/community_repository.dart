import 'package:habit_builder/features/community/domain/post.dart';

/// The community feed: `FirestoreCommunityRepository` in the app,
/// `FakeCommunityRepository` in tests.
abstract interface class CommunityRepository {
  /// Posts, newest first, without those of blocked members.
  Stream<List<Post>> watchPosts();

  /// The comments of [postId], oldest first, without blocked members'.
  Stream<List<Comment>> watchComments(String postId);

  Future<void> addPost(String text);

  /// Deletes one of the user's own posts, with its likes and comments.
  Future<void> deletePost(String postId);

  Future<void> toggleLike(String postId);

  Future<void> addComment(String postId, String text);

  /// Flags [postId] for moderators (App Store guideline 1.2).
  Future<void> reportPost(String postId);

  /// Hides every post and comment by [memberId] from this user.
  Future<void> blockMember(String memberId);
}
