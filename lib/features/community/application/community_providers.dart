import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';

/// The community feed, newest first.
final StreamProvider<List<Post>> postsProvider = StreamProvider<List<Post>>(
  (ref) => ref.watch(communityRepositoryProvider).watchPosts(),
);

/// The current time, for "41m ago". Overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
