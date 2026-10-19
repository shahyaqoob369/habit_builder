import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/text_link.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/domain/auth_validators.dart';
import 'package:habit_builder/features/auth/presentation/auth_messages.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The white "Log in with email" panel docked at the bottom of Login.
class EmailLoginPanel extends ConsumerStatefulWidget {
  const EmailLoginPanel({required this.onSubmit, super.key});

  /// Called with the trimmed email and the password once both are valid.
  final Future<void> Function(String email, String password) onSubmit;

  @override
  ConsumerState<EmailLoginPanel> createState() => _EmailLoginPanelState();
}

class _EmailLoginPanelState extends ConsumerState<EmailLoginPanel> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Errors show only after the first submit, then update as the user types.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Space below the last link: the design's 28 pt, minus the link's touch
  /// padding, or the system navigation bar if that is taller.
  static const _bottomGap = 28.0;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    unawaited(widget.onSubmit(_email.text.trim(), _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final pending = ref.watch(loginFormProvider.select((s) => s.pending));
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.panel,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(l10n.loginWithEmail, style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          // Figma: fields 16 pt below the line, counted from its top.
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: AutofillGroup(
                child: Column(
                  spacing: AppSpacing.xs,
                  children: [
                    AppTextField(
                      controller: _email,
                      hintText: l10n.authEmailHint,
                      icon: AppIcons.mail,
                      fillColor: colors.surfaceTinted,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: fieldValidator(context, AuthValidators.email),
                    ),
                    AppTextField(
                      controller: _password,
                      hintText: l10n.authPasswordHint,
                      icon: AppIcons.lock,
                      fillColor: colors.surfaceTinted,
                      obscurable: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: fieldValidator(
                        context,
                        AuthValidators.password,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 21),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: PrimaryButton(
              label: l10n.loginButton,
              isLoading: pending == AuthMethod.email,
              onPressed: pending == null ? _submit : null,
            ),
          ),
          SizedBox(height: 13 - TextLink.padding.top),
          TextLink(
            label: l10n.loginForgotPassword,
            onTap: () => context.goNamed(AppRoute.resetPassword.name),
          ),
          // Design gap: 6 pt, taken up by the two links' touch padding.
          TextLink(
            prompt: l10n.loginNoAccount,
            label: l10n.loginSignUpLink,
            onTap: () => context.goNamed(AppRoute.signUp.name),
          ),
          SizedBox(
            height: math.max(_bottomGap - TextLink.padding.bottom, bottomInset),
          ),
        ],
      ),
    );
  }
}
