import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/config/app_config.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/links/link_launcher.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/settings_row.dart';
import 'package:habit_builder/features/profile/application/profile_providers.dart';
import 'package:habit_builder/features/settings/presentation/feedback_sheet.dart';
import 'package:habit_builder/features/shell/presentation/widgets/menu_button.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings tab (Figma "Settings"): the profile card, General and Support.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);

    Widget glyph(String icon) => IconTile(child: AppIcon.original(icon));

    return Scaffold(
      body: Column(
        children: [
          AppHeader(title: l10n.settingsTitle, leading: const MenuButton()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppHeader.bottomGap + 18,
                AppSpacing.screen,
                MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
              ),
              children: [
                _ProfileCard(
                  email: user?.email ?? '',
                  onView: () => context.goNamed(AppRoute.profile.name),
                ),
                const SizedBox(height: 17),
                Text(l10n.settingsGeneral, style: AppTextStyles.body),
                const SizedBox(height: 20),
                SettingsRow(
                  icon: const AppIcon.original(AppIcons.settingsBell),
                  title: l10n.settingsNotifications,
                  subtitle: l10n.settingsNotificationsBody,
                  onTap: () =>
                      context.goNamed(AppRoute.notificationSettings.name),
                ),
                const SizedBox(height: AppSpacing.xs),
                SettingsRow(
                  icon: const AppIcon.original(AppIcons.settingsMore),
                  title: l10n.settingsCustomize,
                  subtitle: l10n.settingsCustomizeBody,
                  onTap: () => context.goNamed(AppRoute.customize.name),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.settingsSupport, style: AppTextStyles.body),
                const SizedBox(height: 20),
                for (final (icon, title, onTap) in [
                  (
                    AppIcons.contact,
                    l10n.settingsContact,
                    () => _open(
                      context,
                      ref,
                      Uri(scheme: 'mailto', path: AppConfig.supportEmail),
                    ),
                  ),
                  (
                    AppIcons.feedback,
                    l10n.settingsFeedback,
                    () => unawaited(showFeedbackSheet(context)),
                  ),
                  (
                    AppIcons.privacy,
                    l10n.settingsPrivacy,
                    () => _open(
                      context,
                      ref,
                      Uri.parse(AppConfig.privacyPolicyUrl),
                    ),
                  ),
                  (
                    AppIcons.about,
                    l10n.settingsAbout,
                    () => unawaited(_about(context)),
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: SettingsRow(
                      icon: glyph(icon),
                      title: title,
                      onTap: onTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, WidgetRef ref, Uri uri) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    unawaited(
      ref.read(openLinkProvider)(uri).then((opened) {
        if (!opened) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.settingsCannotOpen(uri.toString()))),
          );
        }
      }),
    );
  }

  static Future<void> _about(BuildContext context) async {
    final l10n = context.l10n;
    String? version;
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version} (${info.buildNumber})';
    } on Exception {
      version = null;
    }
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: version,
      applicationIcon: ClipOval(
        child: Image.asset(AppImages.avatar, width: 48, height: 48),
      ),
      children: [Text(l10n.settingsAboutBody)],
    );
  }
}

/// "Check Your Profile" (Figma "Profile View"): white card, illustration on
/// the right, the user's email and the View button.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.email, required this.onView});

  final String email;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Container(
      height: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              SettingsImages.profileArt,
              width: 222,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(29, 20, 120, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    l10n.settingsCheckProfile,
                    style: AppTextStyles.cardHeading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: FilledButton(
                    onPressed: onView,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      textStyle: AppTextStyles.labelStrong.copyWith(
                        height: 16 / 14,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(l10n.settingsView),
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
