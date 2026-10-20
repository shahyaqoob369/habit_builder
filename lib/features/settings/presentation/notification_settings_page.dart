import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_toggle.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/features/settings/data/settings_repository.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// A settings sub-page of On/Off rows (not in the design: built from its
/// rows and toggles). Used for Notifications and More customization.
class ToggleSettingsPage extends ConsumerWidget {
  const ToggleSettingsPage.notifications({super.key}) : _kind = _Kind.notify;

  const ToggleSettingsPage.customize({super.key}) : _kind = _Kind.customize;

  final _Kind _kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final rows = switch (_kind) {
      _Kind.notify => [
        (
          l10n.settingsHabitReminders,
          l10n.settingsHabitRemindersBody,
          settings.habitReminders,
          (bool v) => controller.setHabitReminders(enabled: v),
        ),
        (
          l10n.settingsCommunityNotifications,
          l10n.settingsCommunityNotificationsBody,
          settings.communityNotifications,
          (bool v) => controller.setCommunityNotifications(enabled: v),
        ),
      ],
      _Kind.customize => [
        (
          l10n.settingsShowQuote,
          l10n.settingsShowQuoteBody,
          settings.showQuote,
          (bool v) => controller.setShowQuote(enabled: v),
        ),
      ],
    };

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: _kind == _Kind.notify
                ? l10n.settingsNotifications
                : l10n.settingsCustomize,
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppHeader.bottomGap + 18,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              children: [
                for (final (title, body, value, onChanged) in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Material(
                      color: context.colors.surface,
                      borderRadius: AppRadii.card,
                      child: InkWell(
                        borderRadius: AppRadii.card,
                        onTap: () => unawaited(onChanged(!value)),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Text(title, style: AppTextStyles.body),
                                    Text(
                                      body,
                                      style: AppTextStyles.label.copyWith(
                                        color: context.colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              AppToggle(
                                value: value,
                                semanticLabel: title,
                                onChanged: (v) => unawaited(onChanged(v)),
                              ),
                            ],
                          ),
                        ),
                      ),
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

enum _Kind { notify, customize }
