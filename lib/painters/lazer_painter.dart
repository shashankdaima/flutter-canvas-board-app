import 'package:canvas_app/models/lazer_point.dart';
import 'package:flutter/material.dart';

class LaserPainter extends CustomPainter {
  final List<LaserPoint> points;
  final Color laserColor;
  final double strokeWidth;
  
  LaserPainter({
    required this.points,
    this.laserColor = Colors.red,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      
      paint.shader = LinearGradient(
        colors: [
          laserColor.withOpacity(current.opacity),
          laserColor.withOpacity(next.opacity),
        ],
      ).createShader(
        Rect.fromPoints(current.point, next.point),
      );

      canvas.drawLine(current.point, next.point, paint);
    }
  }

  @override
  bool shouldRepaint(LaserPainter oldDelegate) => true;
}