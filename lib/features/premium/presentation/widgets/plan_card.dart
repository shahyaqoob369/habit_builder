import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// A plan (Figma "Monthly / Yearly / Lifetime"): price, what it means,
/// a hairline and the plan name; the popular one has an orange header and
/// is taller. The chosen plan gets an orange outline (not in the design).
class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  static const _header = 33.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final (name, detail) = switch (plan.period) {
      PlanPeriod.monthly => (l10n.planMonthly, l10n.planMonthlyDetail),
      PlanPeriod.yearly => (l10n.planYearly, l10n.planYearlyDetail),
      PlanPeriod.lifetime => (l10n.planLifetime, l10n.planLifetimeDetail),
    };
    final badge = plan.badge;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name, ${plan.price}, $detail',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: plan.isMostPopular ? 154 : 135,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: selected ? colors.primary : colors.surface,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            boxShadow: plan.isMostPopular
                ? [
                    BoxShadow(
                      color: colors.backgroundDeep,
                      offset: const Offset(0, 8),
                      blurRadius: 40,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  if (plan.isMostPopular)
                    Container(
                      height: _header,
                      color: colors.primary,
                      alignment: Alignment.center,
                      child: Text(
                        l10n.planMostPopular,
                        style: AppTextStyles.captionStrong,
                      ),
                    ),
                  const SizedBox(height: 26),
                  FittedBox(
                    child: Text(
                      plan.price,
                      style: AppTextStyles.price.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      detail,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: AppTextStyles.micro.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Divider(),
                  SizedBox(
                    height: 29,
                    child: Center(
                      child: Text(name, style: AppTextStyles.captionStrong),
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: _CornerPainter(colors.primary),
                    child: SizedBox.square(
                      dimension: 37,
                      child: Align(
                        alignment: const Alignment(0.45, 0.45),
                        child: Transform.rotate(
                          angle: -0.785,
                          child: Text(badge, style: AppTextStyles.overline),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The orange corner triangle behind a badge.
class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => oldDelegate.color != color;
}
