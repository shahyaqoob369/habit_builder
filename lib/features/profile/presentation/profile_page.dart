import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/core/widgets/chevron.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/settings_row.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/presentation/auth_messages.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/profile/application/profile_providers.dart';
import 'package:habit_builder/features/profile/domain/profile_stats.dart';
import 'package:habit_builder/features/profile/presentation/widgets/progress_ring.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Profile (Figma "Profile Dashboard"): who you are, this week's numbers and
/// daily rings, then billing and the longest streak. Sign out and Delete
/// account sit at the bottom (not in the design; deletion is required by
/// the App Store).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(profileStatsProvider);
    final period = ref.watch(profilePeriodProvider);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l10n.profileTitle,
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.goNamed(AppRoute.settings.name),
            ),
            trailing: HeaderIconButton(
              icon: AppIcons.edit,
              tooltip: l10n.profileEdit,
              onPressed: () => unawaited(_editName(context, ref)),
            ),
          ),
          Expanded(
            child: switch (stats) {
              AsyncValue(value: final stats?) => ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppHeader.bottomGap + 18,
                  AppSpacing.screen,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                ),
                children: [
                  _ProfileCard(
                    name: user?.name ?? l10n.menuGuest,
                    email: user?.email ?? '',
                    period: period,
                    stats: stats,
                    onPeriodTap: () => unawaited(_choosePeriod(context, ref)),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SettingsRow(
                    icon: IconTile(
                      child: AppIcon(AppIcons.card, color: colors.primary),
                    ),
                    title: l10n.profileBilling,
                    onTap: () => context.pushNamed(AppRoute.premium.name),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SettingsRow(
                    icon: const IconTile(
                      child: AppIcon.original(AppIcons.medal),
                    ),
                    title: l10n.profileLongestStreak,
                    value: l10n.statDays(stats.longestStreak),
                    onTap: switch (stats.longestStreakHabit) {
                      final habit? => () => context.goNamed(
                        AppRoute.habitDetail.name,
                        pathParameters: {'id': habit.id},
                      ),
                      null => null,
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  TextButton(
                    onPressed: () => unawaited(_signOut(context, ref)),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      textStyle: AppTextStyles.button,
                    ),
                    child: Text(l10n.menuSignOut),
                  ),
                  TextButton(
                    onPressed: () => unawaited(_deleteAccount(context, ref)),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                      textStyle: AppTextStyles.helper,
                    ),
                    child: Text(l10n.profileDeleteAccount),
                  ),
                ],
              ),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(habitsProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _choosePeriod(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final period = await showAppSheet<ProfilePeriod>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xs,
            children: [
              for (final p in ProfilePeriod.values)
                ListTile(
                  title: Text(_periodLabel(l10n, p), style: AppTextStyles.body),
                  tileColor: context.colors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.card,
                  ),
                  onTap: () => Navigator.of(context).pop(p),
                ),
            ],
          ),
        ),
      ),
    );
    if (period != null) {
      ref.read(profilePeriodProvider.notifier).period = period;
    }
  }

  static Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final current = ref.read(currentUserProvider)?.name ?? '';
    final name = await showAppSheet<String>(
      context: context,
      builder: (context) => _EditNameSheet(initial: current),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(currentUserProvider.notifier).rename(name);
    }
  }

  static Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(currentUserProvider.notifier).signOut();
    if (context.mounted) context.goNamed(AppRoute.login.name);
  }

  static Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final askPassword = ref.read(currentUserProvider)?.hasPassword ?? false;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => _DeleteAccountDialog(askPassword: askPassword),
    );
    // Null: cancelled. Empty: confirmed without a password.
    if (password == null || !context.mounted) return;
    try {
      await ref
          .read(currentUserProvider.notifier)
          .deleteAccount(password: askPassword ? password : null);
    } on AuthException catch (e) {
      if (context.mounted) showAuthFailure(context, e.failure);
      return;
    }
    if (context.mounted) context.goNamed(AppRoute.login.name);
  }
}

String _periodLabel(AppLocalizations l10n, ProfilePeriod period) =>
    switch (period) {
      ProfilePeriod.thisWeek => l10n.profileThisWeek,
      ProfilePeriod.lastWeek => l10n.profileLastWeek,
    };

/// The white card: avatar, name, period, two numbers and the daily rings.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.period,
    required this.stats,
    required this.onPeriodTap,
  });

  final String name;
  final String email;
  final ProfilePeriod period;
  final ProfileStats stats;
  final VoidCallback onPeriodTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final divider = Divider(color: colors.divider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    AppImages.avatar,
                    width: 60,
                    height: 60,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _PeriodButton(
                  label: _periodLabel(l10n, period),
                  onTap: onPeriodTap,
                ),
              ],
            ),
          ),
          divider,
          IntrinsicHeight(
            child: Row(
              children: [
                _Number(
                  label: l10n.profilePerfectDays,
                  value: '${stats.perfectDays}',
                  icon: AppIcons.clock,
                  color: colors.primary,
                ),
                VerticalDivider(width: 1, color: colors.divider),
                _Number(
                  label: l10n.profileTasksCompleted,
                  value: '${stats.tasksCompleted}',
                  icon: AppIcons.flag,
                  color: colors.habitBlue,
                ),
              ],
            ),
          ),
          divider,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: _Rings(
              days: stats.days,
              endsToday: period == ProfilePeriod.thisWeek,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: colors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text(label, style: AppTextStyles.label),
              Chevron(color: colors.textPrimary, direction: AxisDirection.down),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Perfect Days 3" / "Tasks Completed 12" with a round tinted icon.
class _Number extends StatelessWidget {
  const _Number({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                    Text(value, style: AppTextStyles.stat),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                child: AppIcon(icon, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seven daily rings with dates under every other one and "Today" last.
class _Rings extends StatelessWidget {
  const _Rings({required this.days, required this.endsToday});

  final List<DayProgress> days;

  /// Whether the last day is today (orange, labelled "Today").
  final bool endsToday;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('MM/dd', locale);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (i, day) in days.indexed)
          Semantics(
            label: l10n.profileDayProgress(
              DateFormat.MMMEd(locale).format(day.day),
              day.done,
              day.due,
            ),
            excludeSemantics: true,
            child: Column(
              children: [
                ProgressRing(
                  value: day.ratio,
                  label: '${day.done}',
                  color: endsToday && i == days.length - 1
                      ? colors.primary
                      : day.done == 0
                      ? colors.error
                      : colors.textPrimary,
                ),
                const SizedBox(height: 13),
                SizedBox(
                  height: 13,
                  child: i.isEven
                      ? Text(
                          endsToday && i == days.length - 1
                              ? l10n.profileToday
                              : dateFormat.format(day.day),
                          style: AppTextStyles.micro.copyWith(
                            color: colors.textMuted,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.initial});

  final String initial;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.profileEdit, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _name,
                hintText: l10n.authNameHint,
                icon: AppIcons.user,
                fillColor: context.colors.surfaceTinted,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                onFieldSubmitted: (value) => Navigator.of(context).pop(value),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.save,
                onPressed: () => Navigator.of(context).pop(_name.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms deleting the account; email accounts also enter their password
/// (Firebase needs a recent sign-in to delete an account). Pops the
/// password, an empty string when none was asked, or null on Cancel.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.askPassword});

  final bool askPassword;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        l10n.profileDeleteTitle.toUpperCase(),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.profileDeleteBody, textAlign: TextAlign.center),
          if (widget.askPassword) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _password,
              hintText: l10n.profileDeletePassword,
              icon: AppIcons.lock,
              fillColor: context.colors.background,
              obscurable: true,
              autofillHints: const [AutofillHints.password],
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: widget.askPassword && _password.text.isEmpty
              ? null
              : () => Navigator.of(context).pop(_password.text),
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
