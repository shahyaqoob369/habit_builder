import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';

/// A day's progress (Figma "Tracking Habit"): a 42 pt ring filled
/// clockwise from the top over a 10 % track, with the count inside.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.value,
    required this.label,
    required this.color,
    super.key,
  });

  /// 0–1.
  final double value;
  final String label;
  final Color color;

  static const size = 42.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(size),
      painter: _RingPainter(value: value, color: color),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  static const _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, paint..color = color.withValues(alpha: 0.1));
    // Even an empty day shows a dot of color, as the design's "0".
    final sweep = math.max(value, 0.02) * 2 * math.pi;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
