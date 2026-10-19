import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/text_link.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/domain/auth_validators.dart';
import 'package:habit_builder/features/auth/presentation/auth_messages.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Reset Password (Figma "Reset Password"): asks for the account email and
/// sends a reset link, then returns to Login.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _backToLogin() => context.goNamed(AppRoute.login.name);

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final controller = ref.read(resetPasswordFormProvider.notifier);
    if (await controller.sendPasswordReset(email) && mounted) {
      // The messenger outlives this page, so the note shows on Login.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.resetLinkSent(email))),
        );
      _backToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(resetPasswordFormProvider.select((s) => s.failure), (_, f) {
      if (f != null) showAuthFailure(context, f);
    });
    final l10n = context.l10n;
    final colors = context.colors;
    final isSending = ref.watch(
      resetPasswordFormProvider.select((s) => s.isBusy),
    );
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                SizedBox(height: HeaderIconButton.topGap(context)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.screen - HeaderIconButton.inset,
                    ),
                    child: HeaderIconButton(
                      icon: AppIcons.back,
                      tooltip: l10n.resetBackTooltip,
                      onPressed: _backToLogin,
                    ),
                  ),
                ),
                // Figma: 37 pt, but the button sits 5 pt lower here (see
                // HeaderIconButton.topGap), so the title stays at y 120.
                const SizedBox(height: 32 - HeaderIconButton.inset),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: Text(
                    l10n.resetTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline,
                  ),
                ),
                const SizedBox(height: 39),
                Image.asset(
                  AuthImages.resetPassword,
                  width: width,
                  height: width * 264 / 414,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadii.card,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autovalidate,
                        child: Column(
                          children: [
                            Text(
                              l10n.resetInstructions,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.helper,
                            ),
                            const SizedBox(height: 30),
                            AppTextField(
                              controller: _email,
                              hintText: l10n.authEmailHint,
                              fillColor: colors.surfaceTinted,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.send,
                              autofillHints: const [AutofillHints.email],
                              validator: fieldValidator(
                                context,
                                AuthValidators.email,
                              ),
                              onFieldSubmitted: (_) => _send(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            PrimaryButton(
                              label: l10n.resetButton,
                              isLoading: isSending,
                              onPressed: _send,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // At least 24 pt; the design's 100 pt on tall screens.
                SizedBox(height: AppSpacing.xxl - TextLink.padding.top),
                const Spacer(),
                TextLink(
                  prompt: l10n.resetRememberPassword,
                  label: l10n.resetLoginLink,
                  onTap: _backToLogin,
                ),
                SizedBox(
                  height: math.max(
                    34 - TextLink.padding.bottom,
                    padding.bottom,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
