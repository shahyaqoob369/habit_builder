import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';

void main() {
  group('FakeCommunityRepository', () {
    late FakeCommunityRepository repository;

    setUp(() => repository = FakeCommunityRepository());

    Future<T> afterChange<T>(
      Future<void> Function() change,
      T Function(List<Post>) read,
    ) async {
      final next = repository.watchPosts().skip(1).first;
      await change();
      return read(await next);
    }

    test("starts with the design's four posts", () async {
      final posts = await repository.watchPosts().first;
      expect(posts.map((p) => p.author.name), [
        'Jerome',
        'Gretchen',
        'Al',
        'Colin',
      ]);
    });

    test('liking toggles and counts', () async {
      final post = await afterChange(
        () => repository.toggleLike('post-1'),
        (posts) => posts.first,
      );
      expect(post.likedByMe, isFalse);
      expect(post.likeCount, 3099);
    });

    test('new posts go first; comments are added in order', () async {
      final first = await afterChange(
        () => repository.addPost('  Day 7 done!  '),
        (posts) => posts.first,
      );
      expect(first.text, 'Day 7 done!');
      expect(first.author, FakeCommunityRepository.me);

      final post = await afterChange(
        () => repository.addComment('post-2', 'Nice'),
        (posts) => posts.firstWhere((p) => p.id == 'post-2'),
      );
      expect(post.comments.single.text, 'Nice');
    });

    test('blocking hides the member; reporting is recorded', () async {
      final posts = await afterChange(
        () => repository.blockMember('al'),
        (posts) => posts,
      );
      expect(posts.map((p) => p.author.name), isNot(contains('Al')));
      final first = posts.first;
      expect(
        first.comments.map((c) => c.author.name),
        isNot(contains('Al')),
      );

      await repository.reportPost('post-4');
      expect(repository.reported, {'post-4'});
    });
  });
}
