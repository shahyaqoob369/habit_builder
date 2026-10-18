import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_colors.dart';

extension BuildContextX on BuildContext {
  /// Semantic color tokens of the current theme.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
