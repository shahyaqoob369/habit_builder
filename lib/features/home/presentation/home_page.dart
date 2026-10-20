import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/habits/application/habit_actions.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/home/presentation/widgets/habit_grid.dart';
import 'package:habit_builder/features/home/presentation/widgets/quote_card.dart';
import 'package:habit_builder/features/settings/data/settings_repository.dart';
import 'package:habit_builder/features/shell/presentation/widgets/menu_button.dart';
import 'package:habit_builder/features/shell/presentation/widgets/profile_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Home (Figma "Homepage – Tracking Habits"): quote of the day and the
/// habit tracking grid over the dunes background.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// How many days the grid goes back, today included.
  static const historyDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final habits = ref.watch(habitsProvider);
    final today = ref.watch(todayProvider);
    final showQuote = ref.watch(
      settingsProvider.select((s) => s.showQuote),
    );
    final days = [
      for (var i = historyDays - 1; i >= 0; i--)
        today.subtract(Duration(days: i)),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const _Dunes(),
          Column(
            children: [
              AppHeader(
                title: l10n.homeTitle,
                leading: const MenuButton(),
                trailing: ProfileButton(
                  onTap: () => context.goNamed(AppRoute.profile.name),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    top: AppHeader.bottomGap,
                    bottom:
                        MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                  ),
                  children: [
                    if (showQuote) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen,
                        ),
                        child: QuoteCard(
                          quote: l10n.homeQuote,
                          author: l10n.homeQuoteAuthor,
                        ),
                      ),
                      const SizedBox(height: 19),
                    ],
                    switch (habits) {
                      AsyncValue(value: final list?) when list.isEmpty =>
                        MessageView(
                          image: Image.asset(
                            HabitImages.teepee,
                            width: 120,
                            height: 120,
                            excludeFromSemantics: true,
                          ),
                          title: l10n.homeEmptyTitle,
                          body: l10n.homeEmptyBody,
                        ),
                      AsyncValue(value: final list?) => HabitGrid(
                        habits: list,
                        days: days,
                        today: today,
                        onCellTap: (habit, day) => unawaited(
                          ref.read(habitActionsProvider).cycle(habit, day),
                        ),
                        onHabitTap: (habit) => context.goNamed(
                          AppRoute.habitDetail.name,
                          pathParameters: {'id': habit.id},
                        ),
                      ),
                      AsyncValue(hasError: true) => MessageView.error(
                        context,
                        onRetry: () => ref.invalidate(habitsProvider),
                      ),
                      _ => const LoadingView(),
                    },
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

/// Figma "Background": dunes and clouds, 555 × 543 pt, 70 pt past the left
/// edge and 22 pt above the bottom.
class _Dunes extends StatelessWidget {
  const _Dunes();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -70,
      bottom: 22,
      child: Image.asset(
        AppImages.dunes,
        width: 555,
        height: 543,
        excludeFromSemantics: true,
      ),
    );
  }
}
