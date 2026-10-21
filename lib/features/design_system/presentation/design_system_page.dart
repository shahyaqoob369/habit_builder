import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// Developer preview of the design tokens (colors, type, radii, shadows).
///
/// Used to check the theme on a real device against docs/DESIGN_SYSTEM.md.
/// Its labels are developer-facing, so they are not localized.
class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatches = <(String, Color)>[
      ('primary', colors.primary),
      ('primaryDark', colors.primaryDark),
      ('primaryLight', colors.primaryLight),
      ('primarySoft', colors.primarySoft),
      ('background', colors.background),
      ('surface', colors.surface),
      ('surfaceTinted', colors.surfaceTinted),
      ('textPrimary', colors.textPrimary),
      ('textMuted', colors.textMuted),
      ('disabled', colors.disabled),
      ('scrim', colors.scrim),
      ('error', colors.error),
      ('habitOrange', colors.habitOrange),
      ('habitRed', colors.habitRed),
      ('habitBlue', colors.habitBlue),
      ('habitMagenta', colors.habitMagenta),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            const Text(
              'DESIGN SYSTEM',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tokens from Figma · Monumental Habits',
              textAlign: TextAlign.center,
              style: AppTextStyles.helper.copyWith(color: colors.textMuted),
            ),
            _Section(
              title: 'Colors',
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final (name, color) in swatches)
                    _Swatch(name: name, color: color),
                ],
              ),
            ),
            const _Section(title: 'Typography', child: _TypeScale()),
            const _Section(title: 'Radii & shadows', child: _Surfaces()),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase();
    return SizedBox(
      width: 98,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.card,
              border: Border.all(color: context.colors.disabled, width: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(name, style: AppTextStyles.captionStrong),
          Text(
            '#$hex',
            style: AppTextStyles.micro.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  static const _styles = <(String, TextStyle, String)>[
    ('displayLarge', AppTextStyles.displayLarge, 'MONUMENTAL'),
    ('displayMedium', AppTextStyles.displayMedium, 'HABIT COURSES'),
    ('displaySmall', AppTextStyles.displaySmall, 'CREATE NEW HABIT'),
    ('headline', AppTextStyles.headline, 'CREATE YOUR ACCOUNT'),
    ('stat', AppTextStyles.stat, '20 DAYS'),
    ('quote', AppTextStyles.quote, 'WE FIRST MAKE OUR HABITS'),
    ('pickerSelected', AppTextStyles.pickerSelected, '09 : 00'),
    ('price', AppTextStyles.price, r'$29.00'),
    ('pickerOption', AppTextStyles.pickerOption, '08   59'),
    ('timeTile', AppTextStyles.timeTile, '06:30 AM'),
    ('title', AppTextStyles.title, 'New Habit'),
    ('cardTitle', AppTextStyles.cardTitle, '30 Day Journal Challenge'),
    ('lead', AppTextStyles.lead, 'We can help you to be better'),
    ('button', AppTextStyles.button, 'Create Account'),
    ('body', AppTextStyles.body, 'Enter habit name'),
    ('bodyStrong', AppTextStyles.bodyStrong, '37 Lessons (2h 41m)'),
    ('labelStrong', AppTextStyles.labelStrong, 'Read A Book'),
    ('label', AppTextStyles.label, '10'),
    ('helper', AppTextStyles.helper, 'Forgot Password?'),
    ('paragraph', AppTextStyles.paragraph, 'I loved the course!'),
    ('caption', AppTextStyles.caption, '41m ago · 37 Lessons'),
    ('captionStrong', AppTextStyles.captionStrong, 'Most Popular'),
    ('overline', AppTextStyles.overline, 'SUN MON TUE'),
    ('micro', AppTextStyles.micro, '06/14 · Today'),
    ('tiny', AppTextStyles.tiny, '3.1k · 22'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style, sample) in _styles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · ${style.fontFamily} ${style.fontWeight?.value} '
                  '${style.fontSize?.toStringAsFixed(1)}',
                  style: AppTextStyles.micro.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(sample, style: style),
              ],
            ),
          ),
      ],
    );
  }
}

class _Surfaces extends StatelessWidget {
  const _Surfaces();

  @override
  Widget build(BuildContext context) {
    final samples = <(String, BorderRadius, List<BoxShadow>)>[
      ('button r8', AppRadii.button, AppShadows.small),
      ('card r12', AppRadii.card, AppShadows.card),
      ('large r20', AppRadii.large, AppShadows.primary),
      ('pill r25', AppRadii.pill, AppShadows.fab),
    ];
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.xl,
      children: [
        for (final (name, radius, shadow) in samples)
          Container(
            width: 150,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: radius,
              boxShadow: shadow,
            ),
            child: Text(name, style: AppTextStyles.captionStrong),
          ),
      ],
    );
  }
}
