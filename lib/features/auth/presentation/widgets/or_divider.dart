import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// "—— Or sign in with ——": muted label between two faint lines.
class OrDivider extends StatelessWidget {
  const OrDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = Expanded(
      child: Divider(color: colors.textPrimary.withValues(alpha: 0.2)),
    );
    return Row(
      spacing: 10,
      children: [
        line,
        Text(
          label,
          style: AppTextStyles.helper.copyWith(color: colors.textMuted),
        ),
        line,
      ],
    );
  }
}
