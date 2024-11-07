import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, 0, size.width - strokeWidth, size.height - strokeWidth),
        const Radius.circular(15),
      ),
    );

    // Create dashed path effect
    double dashOffset = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (dashOffset < pathMetric.length) {
        final dashEnd = dashOffset + dashLength;
        final extractedPath = pathMetric.extractPath(
            dashOffset, dashEnd.clamp(0.0, pathMetric.length));
        canvas.drawPath(extractedPath, paint);
        dashOffset = dashEnd + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
