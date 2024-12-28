import 'package:flutter/material.dart';

class SelectionRectanglePainter extends CustomPainter {
  final Offset? currentStart;
  final Offset? currentEnd;
  final bool isDrawing;

  SelectionRectanglePainter({
    this.currentStart,
    this.currentEnd,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isDrawing && currentStart != null && currentEnd != null) {
      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final rect = Rect.fromPoints(currentStart!, currentEnd!);
      canvas.drawRect(rect, paint);

      // Draw dashed border
      final dashPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final Path dashPath = Path();
      final double dashWidth = 5.0;
      final double dashSpace = 5.0;
      double distance = 0.0;
      final double perimeter = (rect.width + rect.height) * 2;
      
      while (distance < perimeter) {
        double x = rect.left;
        double y = rect.top;
        
        if (distance < rect.width) {
          x += distance;
        } else if (distance < rect.width + rect.height) {
          x += rect.width;
          y += distance - rect.width;
        } else if (distance < (rect.width * 2) + rect.height) {
          x += rect.width - (distance - (rect.width + rect.height));
          y += rect.height;
        } else {
          x += 0;
          y += rect.height - (distance - ((rect.width * 2) + rect.height));
        }
        
        if (distance == 0) {
          dashPath.moveTo(x, y);
        } else {
          dashPath.lineTo(x, y);
        }
        
        distance += dashWidth;
        if (distance < perimeter) {
          if (distance < rect.width) {
            x = rect.left + distance;
          } else if (distance < rect.width + rect.height) {
            x = rect.left + rect.width;
            y = rect.top + (distance - rect.width);
          } else if (distance < (rect.width * 2) + rect.height) {
            x = rect.left + (rect.width - (distance - (rect.width + rect.height)));
            y = rect.top + rect.height;
          } else {
            x = rect.left;
            y = rect.top + (rect.height - (distance - ((rect.width * 2) + rect.height)));
          }
          dashPath.moveTo(x, y);
        }
        distance += dashSpace;
      }
      
      canvas.drawPath(dashPath, dashPaint);
    }
  }

  @override
  bool shouldRepaint(SelectionRectanglePainter oldDelegate) {
    return oldDelegate.currentStart != currentStart ||
           oldDelegate.currentEnd != currentEnd ||
           oldDelegate.isDrawing != isDrawing;
  }
}