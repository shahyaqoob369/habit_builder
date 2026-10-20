import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Premium (Figma "Subscription Page"). Built in plan step 12.
class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l10n.premiumTitle,
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
