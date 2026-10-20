import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/premium/application/premium_providers.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Habits a free user can have (owner question Q13, default). Premium has
/// no limit ("Unlimited habits" on the paywall).
const freeHabitLimit = 3;

/// Whether the user may add another habit.
final Provider<bool> canAddHabitProvider = Provider<bool>((ref) {
  if (ref.watch(isPremiumProvider).value ?? false) return true;
  return (ref.watch(habitsProvider).value?.length ?? 0) < freeHabitLimit;
});

/// Opens New Habit, or the paywall once a free user has reached the limit.
void openNewHabit(BuildContext context, WidgetRef ref) {
  if (ref.read(canAddHabitProvider)) {
    context.goNamed(AppRoute.newHabit.name);
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(context.l10n.habitLimitReached(freeHabitLimit))),
    );
  unawaited(context.pushNamed(AppRoute.premium.name));
}
