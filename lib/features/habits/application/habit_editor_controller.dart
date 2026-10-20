import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// The preset times offered in the reminders sheet (Figma: 06:00–11:30,
/// every half hour).
const presetReminderTimes = [
  ReminderTime(6, 0),
  ReminderTime(6, 30),
  ReminderTime(7, 0),
  ReminderTime(7, 30),
  ReminderTime(8, 0),
  ReminderTime(8, 30),
  ReminderTime(9, 0),
  ReminderTime(9, 30),
  ReminderTime(10, 0),
  ReminderTime(10, 30),
  ReminderTime(11, 0),
  ReminderTime(11, 30),
];

/// The habit being created or edited.
@immutable
class HabitDraft {
  const HabitDraft({
    this.original,
    this.name = '',
    this.color = HabitColor.orange,
    this.icon = HabitIcon.book,
    this.weekdays = Habit.allWeekdays,
    this.reminders = const [ReminderTime(10, 0)],
    this.notificationsEnabled = false,
    this.showNameError = false,
    this.isSaving = false,
  });

  factory HabitDraft.of(Habit habit) => HabitDraft(
    original: habit,
    name: habit.name,
    color: habit.color,
    icon: habit.icon,
    weekdays: habit.weekdays,
    reminders: habit.reminders,
    notificationsEnabled: habit.notificationsEnabled,
  );

  /// The habit being edited, or null for a new one.
  final Habit? original;

  final String name;
  final HabitColor color;
  final HabitIcon icon;
  final Set<int> weekdays;

  /// Active reminder times, earliest first.
  final List<ReminderTime> reminders;

  final bool notificationsEnabled;

  /// Set when saving was attempted without a name.
  final bool showNameError;

  final bool isSaving;

  bool get isEditing => original != null;

  HabitDraft copyWith({
    String? name,
    HabitColor? color,
    HabitIcon? icon,
    Set<int>? weekdays,
    List<ReminderTime>? reminders,
    bool? notificationsEnabled,
    bool? showNameError,
    bool? isSaving,
  }) {
    return HabitDraft(
      original: original,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      weekdays: weekdays ?? this.weekdays,
      reminders: reminders ?? this.reminders,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showNameError: showNameError ?? this.showNameError,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Holds the New / Edit Habit form. One editor is open at a time; the page
/// [start]s it and the shell's ✓ button [save]s it.
class HabitEditorController extends Notifier<HabitDraft> {
  @override
  HabitDraft build() => const HabitDraft();

  /// Starts editing [habit], or a new habit when it is null. A new habit
  /// takes the next of the four colors (owner question Q4).
  void start(Habit? habit) {
    if (habit != null) {
      state = HabitDraft.of(habit);
      return;
    }
    final count = ref.read(habitsProvider).value?.length ?? 0;
    state = HabitDraft(
      color: HabitColor.values[count % HabitColor.values.length],
    );
  }

  void setName(String name) => state = state.copyWith(
    name: name,
    showNameError: state.showNameError && name.trim().isEmpty,
  );

  void setIcon(HabitIcon icon) => state = state.copyWith(icon: icon);

  void setColor(HabitColor color) => state = state.copyWith(color: color);

  /// Turns [weekday] on or off; the last remaining day stays on.
  void toggleWeekday(int weekday) {
    final days = {...state.weekdays};
    if (!days.remove(weekday)) days.add(weekday);
    if (days.isEmpty) return;
    state = state.copyWith(weekdays: days);
  }

  void setWeekdays(Set<int> weekdays) {
    if (weekdays.isEmpty) return;
    state = state.copyWith(weekdays: {...weekdays});
  }

  /// Turns the reminder at [time] on or off.
  void toggleReminder(ReminderTime time) {
    final times = {...state.reminders};
    if (!times.remove(time)) times.add(time);
    state = state.copyWith(reminders: times.toList()..sort());
  }

  /// Adds (turns on) a reminder at [time].
  void addReminder(ReminderTime time) {
    final times = {...state.reminders, time};
    state = state.copyWith(reminders: times.toList()..sort());
  }

  void setNotifications({required bool enabled}) =>
      state = state.copyWith(notificationsEnabled: enabled);

  /// Saves the draft. Returns false (and flags the name) when it can't.
  Future<bool> save() async {
    final draft = state;
    if (draft.isSaving) return false;
    final name = draft.name.trim();
    if (name.isEmpty) {
      state = draft.copyWith(showNameError: true);
      return false;
    }
    state = draft.copyWith(isSaving: true);
    final repository = ref.read(habitRepositoryProvider);
    final original = draft.original;
    try {
      if (original == null) {
        await repository.addHabit(
          Habit(
            id: '',
            name: name,
            color: draft.color,
            icon: draft.icon,
            createdAt: ref.read(todayProvider),
            weekdays: draft.weekdays,
            reminders: draft.reminders,
            notificationsEnabled: draft.notificationsEnabled,
          ),
        );
      } else {
        await repository.updateHabit(
          original.copyWith(
            name: name,
            color: draft.color,
            icon: draft.icon,
            weekdays: draft.weekdays,
            reminders: draft.reminders,
            notificationsEnabled: draft.notificationsEnabled,
          ),
        );
      }
      return true;
    } finally {
      if (ref.mounted) state = state.copyWith(isSaving: false);
    }
  }

  /// Deletes the habit being edited.
  Future<void> delete() async {
    final original = state.original;
    if (original == null) return;
    await ref.read(habitRepositoryProvider).deleteHabit(original.id);
  }
}

final NotifierProvider<HabitEditorController, HabitDraft> habitEditorProvider =
    NotifierProvider.autoDispose<HabitEditorController, HabitDraft>(
      HabitEditorController.new,
    );
