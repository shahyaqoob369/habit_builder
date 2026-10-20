import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Feedback form (not in the design). Sending is stored with the backend in
/// plan step 21; for now it thanks the user.
Future<void> showFeedbackSheet(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final thanks = context.l10n.feedbackThanks;
  final text = await showAppSheet<String>(
    context: context,
    builder: (_) => const _FeedbackSheet(),
  );
  if (text != null) messenger.showSnackBar(SnackBar(content: Text(thanks)));
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: ValueListenableBuilder(
            valueListenable: _text,
            builder: (context, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsFeedback, style: AppTextStyles.title),
                Text(
                  l10n.feedbackBody,
                  style: AppTextStyles.helper.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _text,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.paragraph,
                  decoration: InputDecoration(
                    hintText: l10n.feedbackHint,
                    fillColor: context.colors.background,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: l10n.feedbackSend,
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(context).pop(value.text.trim()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
