import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// Home quote card (Figma "Quote"): white card, 146 pt tall, with the hiker
/// on the right and the quote over it.
class QuoteCard extends StatelessWidget {
  const QuoteCard({required this.quote, required this.author, super.key});

  final String quote;
  final String author;

  static const height = 146.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: height),
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
              HabitImages.quoteArt,
              width: 204,
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            // Figma: quote at (15, 26) in the card, author 62 pt below.
            padding: const EdgeInsets.fromLTRB(15, 26, 11, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quote.toUpperCase(), style: AppTextStyles.quote),
                const SizedBox(height: 1),
                Text(
                  author.toUpperCase(),
                  style: AppTextStyles.captionStrong.copyWith(
                    color: colors.textMuted,
                    height: 24 / 12,
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
