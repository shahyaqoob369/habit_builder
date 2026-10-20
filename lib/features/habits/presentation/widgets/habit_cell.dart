import 'package:flutter/material.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// A habit day (Figma "Component 3"): a rounded square in the habit color
/// at 10 %, holding a full square ([DayStatus.done]), a lower-left triangle
/// ([DayStatus.missed]) or nothing (not marked). With [showEmpty] false, an
/// unmarked day draws nothing at all, as on Home.
///
/// The Large cell is 54 pt with a 50 pt fill; other sizes scale.
class HabitCell extends StatelessWidget {
  const HabitCell({
    required this.color,
    required this.status,
    this.size = 54,
    this.showEmpty = true,
    super.key,
  });

  final Color color;
  final DayStatus? status;
  final double size;
  final bool showEmpty;

  @override
  Widget build(BuildContext context) {
    if (status == null && !showEmpty) return SizedBox.square(dimension: size);
    return CustomPaint(
      size: Size.square(size),
      painter: _HabitCellPainter(color: color, status: status),
    );
  }
}

class _HabitCellPainter extends CustomPainter {
  const _HabitCellPainter({required this.color, required this.status});

  final Color color;
  final DayStatus? status;

  @override
  void paint(Canvas canvas, Size size) {
    // Proportions of the Large cell: 54 outer, 50 fill, radius 12.
    final k = size.width / 54;
    final radius = Radius.circular(12 * k);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = color.withValues(alpha: 0.1),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(2 * k, 2 * k, 50 * k, 50 * k),
      radius,
    );
    final fill = Paint()..color = color;
    switch (status) {
      case DayStatus.done:
        canvas.drawRRect(inner, fill);
      case DayStatus.missed:
        // The triangle's corners are rounded by stroking an inset triangle
        // with round joins; the square's corner rounds the lower-left one.
        final r = 4 * k;
        final l = inner.left;
        final t = inner.top;
        final s = inner.width;
        final diagonal = r * 1.4142;
        final triangle = Path()
          ..moveTo(l + r, t + r + diagonal)
          ..lineTo(l + r, t + s - r)
          ..lineTo(l + s - r - diagonal, t + s - r)
          ..close();
        canvas
          ..save()
          ..clipRRect(inner)
          ..drawPath(
            triangle,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          )
          ..drawPath(
            triangle,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2 * r
              ..strokeJoin = StrokeJoin.round,
          )
          ..restore();
      case null:
        break;
    }
  }

  @override
  bool shouldRepaint(_HabitCellPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.status != status;
}
