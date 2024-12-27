import 'package:flutter/material.dart';

import '../models/drawing_elements/drawing_element.dart';
import '../models/drawing_elements/pencil_element.dart';

class PagePainter extends CustomPainter {
  final List<DrawingElement> elements;
  final Path? eraserPath;
  final double eraserWidth;

  PagePainter({
    required this.elements,
    this.eraserPath,
    this.eraserWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sort elements by z-index before painting
    final sortedElements = List<DrawingElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Draw all elements
    for (var element in sortedElements) {
      if (element is PencilElement) {
        final paint = Paint()
          ..color = element.isSelected ? Colors.blue : Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        canvas.drawPath(element.path, paint);

        if (element.isSelected) {
          final boundsPaint = Paint()
            ..color = Colors.blue
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

          canvas.drawRect(element.bounds, boundsPaint);
        }
      }
    }

    // Draw eraser preview if in eraser mode
    if (eraserPath != null) {
      final eraserPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = eraserWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true; // Enable anti-aliasing for smoother edges

      canvas.drawPath(eraserPath!, eraserPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PagePainter oldDelegate) {
    return true;
  }
}