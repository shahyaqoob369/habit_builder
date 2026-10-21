import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/share/share_service.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/features/community/data/fake_community_repository.dart';
import 'package:habit_builder/features/community/domain/post.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// What a post card can do, shared by the feed and the post screen.
class PostActions {
  const PostActions(this._ref);

  final WidgetRef _ref;

  void like(Post post) => unawaited(
    _ref.read(communityRepositoryProvider).toggleLike(post.id),
  );

  void share(BuildContext context, Post post, Rect? origin) {
    unawaited(
      _ref
          .read(shareTextProvider)
          .call(
            context.l10n.postShareText(post.author.name, post.text),
            origin: origin,
          ),
    );
    unawaited(
      _ref.read(analyticsProvider).logEvent(AnalyticsEvent.postShared(post.id)),
    );
  }

  /// Report or hide (not in the design; App Store guideline 1.2 asks for
  /// both on user posts), or delete for one's own posts.
  Future<void> showOptions(BuildContext context, Post post) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repository = _ref.read(communityRepositoryProvider);
    final options = post.isMine
        ? [(_PostOption.delete, l10n.postDelete)]
        : [
            (_PostOption.report, l10n.postReport),
            (_PostOption.block, l10n.postBlock(post.author.name)),
          ];
    final choice = await showAppSheet<_PostOption>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xs,
            children: [
              for (final (option, label) in options)
                ListTile(
                  title: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                  tileColor: context.colors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.card,
                  ),
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
    switch (choice) {
      case _PostOption.delete:
        await repository.deletePost(post.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.postDeleted)));
      case _PostOption.report:
        await repository.reportPost(post.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.postReported)));
      case _PostOption.block:
        await repository.blockMember(post.author.id);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postBlocked(post.author.name))),
        );
      case null:
        break;
    }
  }
}

enum _PostOption { report, block, delete }

/// Asks for a new post's text; returns it, or null when cancelled.
Future<String?> showComposeSheet(BuildContext context) {
  return showAppSheet<String>(
    context: context,
    builder: (context) => const _ComposeSheet(),
  );
}

class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet();

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.composeTitle, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              ValueListenableBuilder(
                valueListenable: _text,
                builder: (context, value, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _text,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTextStyles.paragraph,
                      decoration: InputDecoration(
                        hintText: l10n.composeHint,
                        fillColor: context.colors.background,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: l10n.composePost,
                      onPressed: value.text.trim().isEmpty
                          ? null
                          : () => Navigator.of(context).pop(value.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
