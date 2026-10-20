import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The design's small chevron (4 × 10 pt, 2.5 pt round stroke) with its soft
/// glow below (0, 2, blur 6, same color at 50 %).
class Chevron extends StatelessWidget {
  const Chevron({
    required this.color,
    this.direction = AxisDirection.right,
    this.glow = true,
    super.key,
  });

  final Color color;
  final AxisDirection direction;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final quarterTurns = switch (direction) {
      AxisDirection.right => 0,
      AxisDirection.down => 1,
      AxisDirection.left => 2,
      AxisDirection.up => 3,
    };
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: CustomPaint(
        size: const Size(4, 10),
        painter: _ChevronPainter(color: color, glow: glow),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.glow});

  final Color color;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (glow) {
      canvas.drawPath(
        path.shift(const Offset(0, 2)),
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(6)),
      );
    }
    canvas.drawPath(path, stroke);
  }

  // Figma's blur radius to a Gaussian sigma.
  static double _sigma(double radius) => radius / math.sqrt(3);

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glow != glow;
}
