import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/features/community/domain/post.dart';
import 'package:habit_builder/features/community/presentation/time_ago.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// A community post (Figma "Post 1–4"): author and time, share button, a
/// hairline, the text, and likes / comments in the bottom right corner.
class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.now,
    required this.onLike,
    required this.onShare,
    this.onTap,
    this.onOptions,
    this.maxLines = 3,
    super.key,
  });

  final Post post;
  final DateTime now;
  final VoidCallback onLike;
  final ValueChanged<Rect?> onShare;

  /// Opens the post (and its comments).
  final VoidCallback? onTap;

  /// Report / hide (long press).
  final VoidCallback? onOptions;

  /// Lines of text before "…"; null shows it all.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onOptions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Row(
                children: [
                  MemberAvatar(member: post.author),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          style: AppTextStyles.labelStrong.copyWith(
                            height: 1,
                          ),
                        ),
                        Text(
                          formatTimeAgo(context, post.createdAt, now),
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ShareButton(onShare: onShare),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
              child: Text(
                post.text,
                maxLines: maxLines,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: AppTextStyles.paragraph,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Reaction(
                    icon: AppIcon(
                      AppIcons.heart,
                      color: post.likedByMe
                          ? colors.primary
                          : colors.textPrimary.withValues(alpha: 0.2),
                    ),
                    count: formatCount(context, post.likeCount),
                    label: post.likedByMe
                        ? context.l10n.postUnlike
                        : context.l10n.postLike,
                    selected: post.likedByMe,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 16),
                  _Reaction(
                    icon: const AppIcon.original(AppIcons.comment),
                    count: formatCount(context, post.commentCount),
                    label: context.l10n.postComments,
                    muted: true,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A member's round photo.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({required this.member, this.size = 28, super.key});

  final Member member;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        member.avatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onShare});

  final ValueChanged<Rect?> onShare;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.postShare,
      excludeSemantics: true,
      child: InkResponse(
        radius: 24,
        onTap: () {
          // iPad needs to know where the share sheet points from.
          final box = context.findRenderObject() as RenderBox?;
          onShare(
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
          );
        },
        child: const AppIcon.original(AppIcons.share),
      ),
    );
  }
}

/// Heart or bubble with its count (Figma "Reactions and Comments").
class _Reaction extends StatelessWidget {
  const _Reaction({
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.muted = false,
  });

  final Widget icon;
  final String count;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      toggled: muted ? null : selected,
      label: '$label, $count',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          // A larger touch target around the tiny icons.
          padding: const EdgeInsets.all(4),
          child: Row(
            spacing: 3,
            children: [
              icon,
              Text(
                count,
                style: AppTextStyles.tiny.copyWith(
                  color: muted ? colors.textMuted : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
