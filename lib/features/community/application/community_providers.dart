import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';

/// The community feed, newest first.
final StreamProvider<List<Post>> postsProvider = StreamProvider<List<Post>>(
  (ref) => ref.watch(communityRepositoryProvider).watchPosts(),
);

/// The comments of one post, oldest first.
final StreamProviderFamily<List<Comment>, String> commentsProvider =
    StreamProvider.family<List<Comment>, String>(
      (ref, postId) =>
          ref.watch(communityRepositoryProvider).watchComments(postId),
    );

/// The current time, for "41m ago". Overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
