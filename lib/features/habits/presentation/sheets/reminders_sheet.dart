import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/features/habits/application/habit_editor_controller.dart';
import 'package:habit_builder/features/habits/presentation/reminder_format.dart';
import 'package:habit_builder/features/habits/presentation/sheets/time_picker_sheet.dart';
import 'package:habit_builder/features/habits/presentation/widgets/reminder_tile.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Opens the reminders sheet for the habit being edited.
Future<void> showRemindersSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  builder: (_) => const RemindersSheet(),
);

/// Reminders sheet (Figma "Homepage – New Habit Reminder"): the preset
/// times plus any custom ones as On/Off tiles, three per row; "Add
/// Reminder" for another time and a bell to turn notifications on or off.
class RemindersSheet extends ConsumerWidget {
  const RemindersSheet({super.key});

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final draft = ref.watch(habitEditorProvider);
    final editor = ref.read(habitEditorProvider.notifier);
    final times = {...presetReminderTimes, ...draft.reminders}.toList()..sort();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                9,
                AppSpacing.screen,
                0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: _gap,
                mainAxisSpacing: _gap,
                mainAxisExtent: ReminderTile.height,
              ),
              itemCount: times.length,
              itemBuilder: (context, i) {
                final time = times[i];
                return ReminderTile(
                  label: formatReminder(context, time),
                  enabled: draft.reminders.contains(time),
                  onChanged: (_) => editor.toggleReminder(time),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              25,
              AppSpacing.screen,
              (bottom > 34 ? bottom : 34) + 6,
            ),
            child: Row(
              spacing: AppSpacing.screen,
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: l10n.remindersAdd,
                    onPressed: () => unawaited(_addReminder(context, ref)),
                  ),
                ),
                _NotificationsButton(
                  enabled: draft.notificationsEnabled,
                  onChanged: (enabled) =>
                      editor.setNotifications(enabled: enabled),
                  color: colors.textPrimary,
                  activeColor: colors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _addReminder(BuildContext context, WidgetRef ref) async {
    final time = await showTimePickerSheet(context);
    if (time != null) ref.read(habitEditorProvider.notifier).addReminder(time);
  }
}

/// Figma "Reminder Toggle": a 60 pt outlined square with a bell; faded when
/// notifications are off, orange when on.
class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({
    required this.enabled,
    required this.onChanged,
    required this.color,
    required this.activeColor,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color color;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final tint = enabled ? activeColor : color.withValues(alpha: 0.3);
    return Semantics(
      toggled: enabled,
      label: context.l10n.newHabitNotification,
      excludeSemantics: true,
      onTap: () => onChanged(!enabled),
      child: InkWell(
        onTap: () => onChanged(!enabled),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: tint, width: 2),
          ),
          child: AppIcon(AppIcons.bellPlus, color: tint),
        ),
      ),
    );
  }
}
