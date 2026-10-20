import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// "60% off your upgrade" with a live countdown (Figma "Deal").
class OfferCard extends StatefulWidget {
  const OfferCard({
    required this.discountPercent,
    required this.expiresAt,
    required this.clock,
    super.key,
  });

  final int discountPercent;
  final DateTime expiresAt;
  final DateTime Function() clock;

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    var left = widget.expiresAt.difference(widget.clock());
    if (left.isNegative) left = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    final parts = [
      two(left.inHours.clamp(0, 99)),
      two(left.inMinutes.remainder(60)),
      two(left.inSeconds.remainder(60)),
    ];

    return Container(
      height: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              SettingsImages.offerArt,
              width: 181,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.premiumDiscount(widget.discountPercent),
                  style: AppTextStyles.cardHeading.copyWith(
                    color: colors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  l10n.premiumExpiresIn,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.premiumExpiresInLabel(
                    left.inHours,
                    left.inMinutes.remainder(60),
                  ),
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (i, part) in parts.indexed) ...[
                        if (i > 0)
                          const SizedBox(
                            width: 16,
                            child: Text(
                              ':',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyStrong,
                            ),
                          ),
                        Container(
                          width: 41,
                          height: 41,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.textPrimary.withValues(alpha: 0.1),
                            borderRadius: AppRadii.card,
                          ),
                          child: Text(part, style: AppTextStyles.bodyStrong),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
