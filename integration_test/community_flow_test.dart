// Runs against the real Firebase project, on a simulator or device:
//   flutter test integration_test/community_flow_test.dart -d <device id>
// Two throwaway accounts post, like, comment, report and block, then both
// are deleted.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/data/firebase_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/community/data/firestore_community_repository.dart';
import 'package:habit_builder/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

const _password = 'Integration-test-1';

Matcher get _denied => throwsA(
  isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied'),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(
    () => Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  );

  testWidgets('posts, likes, comments, reports, blocks and cleanup', (
    tester,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuthRepository();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final emails = <String>[];

    // Whatever happens, delete the throwaway accounts.
    addTearDown(() async {
      for (final email in emails) {
        try {
          await auth.signOut();
          await auth.signInWithEmail(email: email, password: _password);
          await auth.deleteAccount(password: _password);
        } on Object {
          // Already deleted.
        }
      }
    });

    Future<FirestoreCommunityRepository> signUp(String name) async {
      await auth.signOut();
      final email = 'integration-$name-$stamp@example.com'.toLowerCase();
      emails.add(email);
      final user = await auth.signUp(
        SignUpDetails(
          name: name,
          email: email,
          password: _password,
          keepSignedIn: true,
          marketingOptIn: false,
        ),
      );
      return FirestoreCommunityRepository(
        uid: user.id,
        authorName: () => name,
      );
    }

    Future<DocumentSnapshot<Map<String, Object?>>> serverPost(String id) =>
        firestore.doc('posts/$id').get(const GetOptions(source: Source.server));

    // Ana posts and comments on her own post.
    final ana = await signUp('Ana');
    await ana.addPost('Day 7 done!');
    final anaPost = (await ana.watchPosts().firstWhere(
      (posts) => posts.any((p) => p.text == 'Day 7 done!'),
    )).firstWhere((p) => p.text == 'Day 7 done!');
    expect(anaPost.isMine, isTrue);
    expect(anaPost.author.name, 'Ana');
    final postId = anaPost.id;
    await ana.addComment(postId, 'Feels great');
    await firestore.waitForPendingWrites();
    expect((await serverPost(postId)).data()?['commentCount'], 1);

    // Ben sees it, likes it and comments.
    final ben = await signUp('Ben');
    var post = (await ben.watchPosts().firstWhere(
      (posts) => posts.any((p) => p.id == postId),
    )).firstWhere((p) => p.id == postId);
    expect(post.isMine, isFalse);
    await ben.toggleLike(postId);
    await ben.addComment(postId, 'Well done!');
    await firestore.waitForPendingWrites();
    var data = (await serverPost(postId)).data()!;
    expect(data['likeCount'], 1);
    expect(data['commentCount'], 2);
    post = (await ben.watchPosts().firstWhere(
      (posts) => posts.any((p) => p.id == postId && p.likedByMe),
    )).firstWhere((p) => p.id == postId);
    expect(post.likeCount, 1);
    final comments = await ben
        .watchComments(postId)
        .firstWhere((c) => c.length == 2);
    expect(comments.map((c) => c.text), ['Feels great', 'Well done!']);

    // The rules stop tampering.
    final postRef = firestore.doc('posts/$postId');
    await expectLater(postRef.update({'likeCount': 99}), _denied);
    await expectLater(postRef.delete(), _denied);
    await expectLater(
      postRef.collection('comments').add({
        'authorId': FirebaseAuth.instance.currentUser!.uid,
        'authorName': 'Ben',
        'text': 'No counter',
        'createdAt': FieldValue.serverTimestamp(),
      }),
      _denied,
    );
    await expectLater(
      postRef.update({'text': 'Edited by someone else'}),
      _denied,
    );

    // Reporting works but reports can't be read in the app.
    await ben.reportPost(postId);
    await firestore.waitForPendingWrites();
    await expectLater(firestore.collection('reports').get(), _denied);

    // Blocking Ana hides her post and comment for Ben.
    await ben.blockMember(anaPost.author.id);
    final feed = await ben.watchPosts().firstWhere(
      (posts) => posts.every((p) => p.id != postId),
    );
    expect(feed.where((p) => p.id == postId), isEmpty);

    // Ben deletes his account: his like and comment go, counters follow.
    await auth.deleteAccount(password: _password);
    emails.remove(emails.last);

    // Ana signs back in and sees the counters back down.
    await auth.signInWithEmail(email: emails.single, password: _password);
    data = (await serverPost(postId)).data()!;
    expect(data['likeCount'], 0);
    expect(data['commentCount'], 1);

    // Ana deletes her account: her post goes too.
    await auth.deleteAccount(password: _password);
    emails.clear();
    final checker = await signUp('Checker');
    expect((await serverPost(postId)).exists, isFalse);
    expect(
      (await checker.watchPosts().first).where((p) => p.id == postId),
      isEmpty,
    );
  });
}
