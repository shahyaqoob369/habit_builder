import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_toggle.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/features/habits/application/habit_editor_controller.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/presentation/habit_colors.dart';
import 'package:habit_builder/features/habits/presentation/reminder_format.dart';
import 'package:habit_builder/features/habits/presentation/sheets/frequency_sheet.dart';
import 'package:habit_builder/features/habits/presentation/sheets/icon_picker_sheet.dart';
import 'package:habit_builder/features/habits/presentation/sheets/reminders_sheet.dart';
import 'package:habit_builder/features/habits/presentation/widgets/form_row.dart';
import 'package:habit_builder/features/habits/presentation/widgets/frequency_card.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_name_row.dart';
import 'package:habit_builder/features/habits/presentation/widgets/start_habit_card.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// New Habit and Edit Habit (Figma "Homepage – New Habit"): name and icon,
/// frequency, reminders and notifications. The shell's ✓ button saves.
class NewHabitPage extends ConsumerStatefulWidget {
  const NewHabitPage({this.habitId, super.key});

  /// The habit to edit, or null to create one.
  final String? habitId;

  @override
  ConsumerState<NewHabitPage> createState() => _NewHabitPageState();
}

class _NewHabitPageState extends ConsumerState<NewHabitPage> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    final id = widget.habitId;
    final habits = ref.read(habitsProvider).value ?? const [];
    final habit = id == null
        ? null
        : habits.where((h) => h.id == id).firstOrNull;
    // Providers can't change while the tree builds.
    unawaited(
      Future.microtask(() {
        if (!mounted) return;
        ref.read(habitEditorProvider.notifier).start(habit);
        _name.text = habit?.name ?? '';
      }),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _choosePreset() async {
    final preset = await showFrequencySheet(context);
    if (preset != null) {
      ref.read(habitEditorProvider.notifier).setWeekdays(preset.days);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.deleteHabitTitle.toUpperCase(),
          textAlign: TextAlign.center,
        ),
        content: Text(l10n.deleteHabitBody, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(habitEditorProvider.notifier).delete();
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final draft = ref.watch(habitEditorProvider);
    final editor = ref.read(habitEditorProvider.notifier);
    final accent = draft.color.resolve(colors);
    final reminders = draft.reminders;
    final reminderLabel = reminders.isEmpty
        ? l10n.reminderNone
        : reminders.length == 1
        ? formatReminder(context, reminders.first, compact: true)
        : l10n.reminderMore(
            formatReminder(context, reminders.first, compact: true),
            reminders.length - 1,
          );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -70,
            bottom: 22,
            child: Image.asset(
              AppImages.dunes,
              width: 555,
              height: 543,
              excludeFromSemantics: true,
            ),
          ),
          Column(
            children: [
              AppHeader(
                title: draft.isEditing
                    ? l10n.editHabitTitle
                    : l10n.newHabitTitle,
                leading: HeaderIconButton(
                  icon: AppIcons.back,
                  tooltip: l10n.backTooltip,
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppHeader.bottomGap,
                          AppSpacing.screen,
                          // Figma: the card ends 15 pt above the ✓ button.
                          MediaQuery.paddingOf(context).bottom + 15,
                        ),
                        child: Column(
                          children: [
                            HabitNameRow(
                              controller: _name,
                              icon: draft.icon,
                              iconColor: colors.textPrimary,
                              onChanged: editor.setName,
                              onIconTap: () =>
                                  unawaited(showIconPickerSheet(context)),
                              errorText: draft.showNameError
                                  ? l10n.newHabitNameRequired
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FrequencyCard(
                              weekdays: draft.weekdays,
                              color: accent,
                              onDayTap: editor.toggleWeekday,
                              onPresetTap: () => unawaited(_choosePreset()),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FormRow(
                              label: l10n.newHabitReminder,
                              trailing: ValueChevron(value: reminderLabel),
                              onTap: () =>
                                  unawaited(showRemindersSheet(context)),
                            ),
                            const SizedBox(height: 11),
                            FormRow(
                              label: l10n.newHabitNotification,
                              trailing: AppToggle(
                                value: draft.notificationsEnabled,
                                semanticLabel: l10n.newHabitNotification,
                                onChanged: (enabled) =>
                                    editor.setNotifications(enabled: enabled),
                              ),
                            ),
                            if (draft.isEditing) ...[
                              const SizedBox(height: AppSpacing.xl),
                              TextButton(
                                onPressed: () => unawaited(_delete()),
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.error,
                                  textStyle: AppTextStyles.button,
                                ),
                                child: Text(l10n.deleteHabit),
                              ),
                            ],
                            const Spacer(),
                            if (!draft.isEditing) ...[
                              const SizedBox(height: AppSpacing.xxl),
                              StartHabitCard(
                                title: l10n.startHabitTitle,
                                body: l10n.startHabitBody,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
