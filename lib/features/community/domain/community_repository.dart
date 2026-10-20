import 'package:habit_builder/features/community/domain/post.dart';

/// The community feed. A fake with sample posts for now; Firestore and
/// Cloud Functions arrive in plan step 24.
abstract interface class CommunityRepository {
  /// Posts, newest first, without those of blocked members.
  Stream<List<Post>> watchPosts();

  Future<void> addPost(String text);

  Future<void> toggleLike(String postId);

  Future<void> addComment(String postId, String text);

  /// Flags [postId] for moderators (App Store guideline 1.2).
  Future<void> reportPost(String postId);

  /// Hides every post and comment by [memberId] from this user.
  Future<void> blockMember(String memberId);
}
