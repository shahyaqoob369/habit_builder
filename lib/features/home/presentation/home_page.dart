import 'package:flutter/material.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/features/shell/presentation/widgets/menu_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Homepage tab (Figma "Homepage"). Content arrives in its own plan step.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(title: context.l10n.homeTitle, leading: const MenuButton()),
        ],
      ),
    );
  }
}
