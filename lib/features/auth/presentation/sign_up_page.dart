import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/widgets/app_checkbox.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/text_link.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_validators.dart';
import 'package:habit_builder/features/auth/presentation/auth_messages.dart';
import 'package:habit_builder/features/auth/presentation/widgets/or_divider.dart';
import 'package:habit_builder/features/auth/presentation/widgets/social_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Sign Up (Figma "Sign Up page"): name, email, password, two options, and
/// Google / Facebook as alternatives.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _keepSignedIn = true;

  /// Unticked by default (the design shows it ticked): marketing consent
  /// must be opted into, not pre-selected.
  bool _marketingOptIn = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  AuthFormController get _controller => ref.read(signUpFormProvider.notifier);

  Future<void> _run(Future<bool> Function() request) async {
    if (await request() && mounted) {
      context.goNamed(AppRoute.home.name);
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    final details = SignUpDetails(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      keepSignedIn: _keepSignedIn,
      marketingOptIn: _marketingOptIn,
    );
    await _run(() => _controller.signUp(details));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpFormProvider.select((s) => s.failure), (_, failure) {
      if (failure != null) showAuthFailure(context, failure);
    });
    final l10n = context.l10n;
    final pending = ref.watch(signUpFormProvider.select((s) => s.pending));
    final busy = pending != null;
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                children: [
                  // Figma: 4 pt below the status bar.
                  SizedBox(height: padding.top + 4),
                  Image.asset(
                    AuthImages.signUp,
                    width: 188,
                    height: 200,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 21),
                  Text(
                    l10n.signUpTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Form(
                    key: _formKey,
                    autovalidateMode: _autovalidate,
                    child: _SignUpFields(
                      name: _name,
                      email: _email,
                      password: _password,
                      onSubmit: _createAccount,
                    ),
                  ),
                  // Design gaps (28, 19, 28) minus the checkboxes' padding.
                  SizedBox(height: 28 - AppCheckbox.padding.top),
                  _Option(
                    label: l10n.signUpKeepSignedIn,
                    value: _keepSignedIn,
                    onChanged: (value) => setState(() => _keepSignedIn = value),
                  ),
                  SizedBox(height: 19 - AppCheckbox.padding.vertical),
                  _Option(
                    label: l10n.signUpMarketingOptIn,
                    value: _marketingOptIn,
                    onChanged: (value) =>
                        setState(() => _marketingOptIn = value),
                  ),
                  SizedBox(height: 28 - AppCheckbox.padding.bottom),
                  PrimaryButton(
                    label: l10n.signUpButton,
                    isLoading: pending == AuthMethod.email,
                    onPressed: busy ? null : _createAccount,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OrDivider(label: l10n.signUpOrSignInWith),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    spacing: AppSpacing.md,
                    children: [
                      Expanded(
                        child: SocialButton(
                          provider: SocialProvider.google,
                          label: l10n.authGoogle,
                          isLoading: pending == AuthMethod.google,
                          onPressed: busy
                              ? null
                              : () => _run(_controller.signInWithGoogle),
                        ),
                      ),
                      Expanded(
                        child: SocialButton(
                          provider: SocialProvider.facebook,
                          label: l10n.authFacebook,
                          isLoading: pending == AuthMethod.facebook,
                          onPressed: busy
                              ? null
                              : () => _run(_controller.signInWithFacebook),
                        ),
                      ),
                    ],
                  ),
                  // At least the design's 32 pt; more on tall screens.
                  SizedBox(height: 32 - TextLink.padding.top),
                  const Spacer(),
                  TextLink(
                    prompt: l10n.signUpHaveAccount,
                    label: l10n.signUpSignInLink,
                    onTap: () => context.goNamed(AppRoute.login.name),
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
          ),
        ],
      ),
    );
  }
}

class _SignUpFields extends StatelessWidget {
  const _SignUpFields({
    required this.name,
    required this.email,
    required this.password,
    required this.onSubmit,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AutofillGroup(
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          AppTextField(
            controller: name,
            hintText: l10n.authNameHint,
            icon: AppIcons.user,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: fieldValidator(context, AuthValidators.name),
          ),
          AppTextField(
            controller: email,
            hintText: l10n.authEmailHint,
            icon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: fieldValidator(context, AuthValidators.email),
          ),
          AppTextField(
            controller: password,
            hintText: l10n.authPasswordHint,
            icon: AppIcons.lock,
            obscurable: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: fieldValidator(context, AuthValidators.newPassword),
            onFieldSubmitted: (_) => onSubmit(),
          ),
        ],
      ),
    );
  }
}

/// A checkbox row, aligned to the start like the design.
class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppCheckbox(label: label, value: value, onChanged: onChanged),
    );
  }
}
