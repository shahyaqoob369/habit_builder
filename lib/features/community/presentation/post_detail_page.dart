import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/community/application/community_providers.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';
import 'package:habit_builder/features/community/presentation/post_actions.dart';
import 'package:habit_builder/features/community/presentation/time_ago.dart';
import 'package:habit_builder/features/community/presentation/widgets/post_card.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// A post with its comments (not in the design: built from the post card
/// and the app's fields).
class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({required this.postId, super.key});

  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    _comment.clear();
    await ref.read(communityRepositoryProvider).addComment(widget.postId, text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final posts = ref.watch(postsProvider);
    final now = ref.watch(clockProvider)();
    final post = posts.value?.where((p) => p.id == widget.postId).firstOrNull;
    final comments = ref.watch(commentsProvider(widget.postId)).value ?? [];
    final actions = PostActions(ref);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l10n.postTitle,
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: switch (posts) {
              AsyncValue(hasValue: true) when post == null => MessageView(
                title: l10n.postNotFoundTitle,
                body: l10n.postNotFoundBody,
              ),
              AsyncValue(hasValue: true) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppHeader.bottomGap + 18,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                children: [
                  PostCard(
                    post: post!,
                    now: now,
                    maxLines: null,
                    onLike: () => actions.like(post),
                    onShare: (origin) => actions.share(context, post, origin),
                    onOptions: () =>
                        unawaited(actions.showOptions(context, post)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (comments.isEmpty)
                    Text(
                      l10n.postNoComments,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.helper.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  for (final comment in comments)
                    _CommentTile(comment: comment, now: now),
                ],
              ),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(postsProvider),
              ),
              _ => const LoadingView(),
            },
          ),
          if (post != null)
            _CommentBar(controller: _comment, onSend: () => unawaited(_send())),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.now});

  final Comment comment;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          MemberAvatar(member: comment.author),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.author.name,
                          style: AppTextStyles.labelStrong,
                        ),
                      ),
                      Text(
                        formatTimeAgo(context, comment.createdAt, now),
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(comment.text, style: AppTextStyles.paragraph),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Comment field docked above the bottom bar.
class _CommentBar extends StatelessWidget {
  const _CommentBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xs,
        AppSpacing.screen,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xs,
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          style: AppTextStyles.paragraph,
          decoration: InputDecoration(
            hintText: l10n.postCommentHint,
            suffixIcon: IconButton(
              tooltip: l10n.postSendComment,
              onPressed: value.text.trim().isEmpty ? null : onSend,
              icon: Icon(
                Icons.send_rounded,
                color: value.text.trim().isEmpty
                    ? colors.textMuted
                    : colors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
