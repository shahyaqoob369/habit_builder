import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_bottom_bar.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_drawer.dart';

/// The signed-in frame around the four tabs: the bottom bar with its center
/// button, and the side menu.
///
/// Each tab keeps its own navigation stack ([StatefulNavigationShell]).
/// Pages draw edge to edge behind the bar; their scrollables get the bar's
/// height as bottom padding through [MediaQuery].
class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  void _selectTab(AppTab tab) {
    final shell = widget.navigationShell;
    // Tapping the current tab again returns to its first screen.
    shell.goBranch(tab.index, initialLocation: tab.index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
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
          fabMode: FabMode.add,
          onFabPressed: () => context.goNamed(AppRoute.newHabit.name),
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
