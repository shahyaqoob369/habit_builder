import 'package:flutter/painting.dart';
import 'package:habit_builder/app/theme/app_colors.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

extension HabitColorX on HabitColor {
  /// This habit color's theme token.
  Color resolve(AppColors colors) => switch (this) {
    HabitColor.orange => colors.habitOrange,
    HabitColor.red => colors.habitRed,
    HabitColor.blue => colors.habitBlue,
    HabitColor.magenta => colors.habitMagenta,
  };
}
