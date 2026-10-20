import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/habits/application/habit_editor_controller.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_bottom_bar.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_drawer.dart';

/// The signed-in frame around the four tabs: the bottom bar with its center
/// button, and the side menu.
///
/// Each tab keeps its own navigation stack ([StatefulNavigationShell]).
/// Pages draw edge to edge behind the bar; their scrollables get the bar's
/// height as bottom padding through [MediaQuery].
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    required this.navigationShell,
    this.topRouteName,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// The name of the screen on top; the habit editor turns the center
  /// button into ✓ (save).
  final String? topRouteName;

  /// Routes whose center button saves the habit being edited.
  static final Set<String> editorRoutes = {
    AppRoute.newHabit.name,
    AppRoute.editHabit.name,
  };

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  void _selectTab(AppTab tab) {
    final shell = widget.navigationShell;
    // Tapping the current tab again returns to its first screen.
    shell.goBranch(tab.index, initialLocation: tab.index == shell.currentIndex);
  }

  Future<void> _saveHabit() async {
    final saved = await ref.read(habitEditorProvider.notifier).save();
    if (saved && mounted) GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final editing = AppShell.editorRoutes.contains(widget.topRouteName);
    return AppShellScope(
      openMenu: _openMenu,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        drawer: AppDrawer(
          currentTab: AppTab.values[shell.currentIndex],
          onTabSelected: (tab) {
            _scaffoldKey.currentState?.closeDrawer();
            _selectTab(tab);
          },
        ),
        body: shell,
        bottomNavigationBar: AppBottomBar(
          currentTab: AppTab.values[shell.currentIndex],
          onTabSelected: _selectTab,
          fabMode: editing ? FabMode.save : FabMode.add,
          onFabPressed: editing
              ? () => unawaited(_saveHabit())
              : () => context.goNamed(AppRoute.newHabit.name),
        ),
      ),
    );
  }
}

/// Gives pages inside the shell access to it, for the menu button.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    required this.openMenu,
    required super.child,
    super.key,
  });

  /// Opens the side menu.
  final VoidCallback openMenu;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      openMenu != oldWidget.openMenu;
}
