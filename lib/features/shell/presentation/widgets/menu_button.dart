import 'package:flutter/material.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/features/shell/presentation/app_shell.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// The ☰ header button that opens the side menu.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: AppIcons.menu,
      tooltip: context.l10n.menuTooltip,
      onPressed: () => AppShellScope.maybeOf(context)?.openMenu(),
    );
  }
}
