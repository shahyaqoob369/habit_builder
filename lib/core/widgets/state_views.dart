import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Centered spinner for content that is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}

/// A short message with an optional picture and action, for empty and
/// error states. Not in the design; uses its type and buttons.
class MessageView extends StatelessWidget {
  const MessageView({
    required this.title,
    required this.body,
    this.image,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Load failed: a generic message and a retry button.
  factory MessageView.error(BuildContext context, {VoidCallback? onRetry}) {
    final l10n = context.l10n;
    return MessageView(
      title: l10n.loadErrorTitle,
      body: l10n.loadErrorBody,
      actionLabel: onRetry == null ? null : l10n.retry,
      onAction: onRetry,
    );
  }

  final String title;
  final String body;
  final Widget? image;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image case final image?) ...[
            image,
            const SizedBox(height: AppSpacing.xl),
          ],
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.helper.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: actionLabel, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
