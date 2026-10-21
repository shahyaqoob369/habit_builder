import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/features/auth/application/auth_form_controller.dart';
import 'package:habit_builder/features/auth/presentation/auth_messages.dart';
import 'package:habit_builder/features/auth/presentation/widgets/email_login_panel.dart';
import 'package:habit_builder/features/auth/presentation/widgets/social_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Login (Figma "Login Page"): illustrated welcome with social sign-in on
/// top, the email login panel docked at the bottom.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginFormProvider.select((state) => state.failure), (
      _,
      failure,
    ) {
      if (failure != null) showAuthFailure(context, failure);
    });

    final controller = ref.read(loginFormProvider.notifier);
    Future<void> signIn(Future<bool> Function() request) async {
      if (await request() && context.mounted) {
        context.goNamed(AppRoute.home.name);
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: _Welcome(
                    onGoogle: () => signIn(controller.signInWithGoogle),
                    onApple: () => signIn(controller.signInWithApple),
                  ),
                ),
                EmailLoginPanel(
                  onSubmit: (email, password) => signIn(
                    () => controller.signIn(email: email, password: password),
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

/// The top of the screen: illustration, help button, title and the social
/// buttons, kept just above the panel whatever the screen height.
class _Welcome extends ConsumerWidget {
  const _Welcome({required this.onGoogle, required this.onApple});

  final VoidCallback onGoogle;
  final VoidCallback onApple;

  /// The 414 × 692 illustration ends this far below the panel's top edge
  /// (Figma: panel at y 540, illustration fade until y 692).
  static const double _artBelowPanel = 692 - 540;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(loginFormProvider.select((s) => s.pending));
    final busy = pending != null;
    final scale = MediaQuery.sizeOf(context).width / 414;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Anchored to the panel; covers the space above it on tall screens.
        Positioned.fill(
          bottom: -_artBelowPanel * scale,
          child: Image.asset(
            AuthImages.loginBackground,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
        ),
        Column(
          children: [
            SizedBox(height: HeaderIconButton.topGap(context)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: AppSpacing.screen - HeaderIconButton.inset,
                ),
                child: HeaderIconButton(
                  icon: AppIcons.help,
                  tooltip: l10n.loginHelpTooltip,
                  onPressed: () => unawaited(_showHelp(context)),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.loginTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.displaySmall,
              ),
            ),
            const SizedBox(height: 41),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                spacing: AppSpacing.xs,
                children: [
                  SocialButton(
                    provider: SocialProvider.google,
                    label: l10n.authContinueWithGoogle,
                    wide: true,
                    isLoading: pending == AuthMethod.google,
                    onPressed: busy ? null : onGoogle,
                  ),
                  // In Facebook's place in the design (owner, 2026-10-21).
                  if (appleSignInShown)
                    SocialButton(
                      provider: SocialProvider.apple,
                      label: l10n.authContinueWithApple,
                      wide: true,
                      isLoading: pending == AuthMethod.apple,
                      onPressed: busy ? null : onApple,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ],
    );
  }

  /// Not in the design: a short how-to, in the app's dialog style.
  static Future<void> _showHelp(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.loginHelpTitle.toUpperCase(),
          textAlign: TextAlign.center,
        ),
        content: Text(l10n.loginHelpBody),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          PrimaryButton(
            label: l10n.loginHelpClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
