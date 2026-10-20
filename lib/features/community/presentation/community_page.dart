import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/community/application/community_providers.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/presentation/post_actions.dart';
import 'package:habit_builder/features/community/presentation/widgets/post_card.dart';
import 'package:habit_builder/features/shell/presentation/widgets/menu_button.dart';
import 'package:habit_builder/features/shell/presentation/widgets/profile_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Community tab (Figma "Community Page"): the feed of post cards, with a
/// composer on top (not in the design).
class CommunityPage extends ConsumerWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final posts = ref.watch(postsProvider);
    final now = ref.watch(clockProvider)();
    final actions = PostActions(ref);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l10n.communityTitle,
            leading: const MenuButton(),
            trailing: const ProfileButton(),
          ),
          Expanded(
            child: switch (posts) {
              AsyncValue(value: final list?) => ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  // Figma: the first post starts at y 125.
                  AppHeader.bottomGap + 18,
                  AppSpacing.screen,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                ),
                children: [
                  _Composer(
                    onTap: () => unawaited(_compose(context, ref)),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (list.isEmpty)
                    MessageView(
                      title: l10n.communityEmptyTitle,
                      body: l10n.communityEmptyBody,
                    ),
                  for (final post in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: PostCard(
                        post: post,
                        now: now,
                        onLike: () => actions.like(post),
                        onShare: (origin) =>
                            actions.share(context, post, origin),
                        onOptions: () =>
                            unawaited(actions.showOptions(context, post)),
                        onTap: () => context.goNamed(
                          AppRoute.postDetail.name,
                          pathParameters: {'id': post.id},
                        ),
                      ),
                    ),
                ],
              ),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(postsProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _compose(BuildContext context, WidgetRef ref) async {
    final text = await showComposeSheet(context);
    if (text != null) {
      await ref.read(communityRepositoryProvider).addPost(text);
    }
  }
}

/// "Share your progress…" row that opens the composer.
class _Composer extends StatelessWidget {
  const _Composer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            spacing: 10,
            children: [
              ClipOval(
                child: Image.asset(
                  AppImages.avatar,
                  width: 28,
                  height: 28,
                  excludeFromSemantics: true,
                ),
              ),
              Expanded(
                child: Text(
                  context.l10n.composeHint,
                  style: AppTextStyles.helper.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
