import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/features/habits/application/habit_editor_controller.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/habit_colors.dart';
import 'package:habit_builder/features/habits/presentation/habit_icons.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Opens the icon and color picker for the habit being edited.
Future<void> showIconPickerSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  builder: (_) => const IconPickerSheet(),
);

/// Icon and color picker. Not in the design (owner questions Q4, Q5):
/// built from its tiles, colors and buttons.
class IconPickerSheet extends ConsumerWidget {
  const IconPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final draft = ref.watch(habitEditorProvider);
    final editor = ref.read(habitEditorProvider.notifier);
    final accent = draft.color.resolve(colors);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.iconPickerTitle, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              children: [
                for (final icon in HabitIcon.values)
                  _Choice(
                    selected: icon == draft.icon,
                    label: icon.name,
                    color: accent,
                    onTap: () => editor.setIcon(icon),
                    child: FaIcon(
                      icon.glyph,
                      size: 22,
                      color: icon == draft.icon
                          ? colors.surface
                          : colors.textPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.iconPickerColor, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            Row(
              spacing: AppSpacing.md,
              children: [
                for (final color in HabitColor.values)
                  _ColorDot(
                    color: color.resolve(colors),
                    selected: color == draft.color,
                    label: color.name,
                    onTap: () => editor.setColor(color),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: l10n.done,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.label,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? color : context.colors.background,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.card,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: AppRadii.card,
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}
