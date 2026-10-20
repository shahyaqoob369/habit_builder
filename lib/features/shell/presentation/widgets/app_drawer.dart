import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/features/profile/application/profile_providers.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_bottom_bar.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Side menu behind the ☰ button. Not in the design: built from the app's
/// own pieces (cream sheet, white rows, tab illustrations).
class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            Row(
              spacing: AppSpacing.md,
              children: [
                ClipOval(
                  child: Image.asset(
                    AppImages.avatar,
                    width: 60,
                    height: 60,
                    excludeFromSemantics: true,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(
                        user?.name ?? l10n.menuGuest,
                        style: AppTextStyles.cardTitle,
                      ),
                      if (user != null)
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            for (final tab in AppTab.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _MenuRow(
                  tab: tab,
                  selected: tab == currentTab,
                  onTap: () => onTabSelected(tab),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              title: Text(l10n.menuSignOut, style: AppTextStyles.button),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
              onTap: () => unawaited(_signOut(context, ref)),
            ),
            if (kDebugMode)
              ListTile(
                title: Text(
                  'Design system',
                  style: AppTextStyles.helper.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                onTap: () => context.goNamed(AppRoute.designSystem.name),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(currentUserProvider.notifier).signOut();
    if (context.mounted) context.goNamed(AppRoute.login.name);
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.surface : Colors.transparent,
      borderRadius: AppRadii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            spacing: AppSpacing.lg,
            children: [
              SizedBox(
                width: 50,
                height: 41,
                child: Image.asset(tab.image, excludeFromSemantics: true),
              ),
              Expanded(
                child: Text(
                  tab.label(context.l10n),
                  style: selected ? AppTextStyles.button : AppTextStyles.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
