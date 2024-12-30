import 'package:flutter/material.dart';

import '../models/drawing_elements/drawing_element.dart';
import '../models/drawing_elements/pencil_element.dart';
import '../models/drawing_elements/text_element.dart';
import '../widgets/page_content.dart';

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
      if (element is TextElement&& !element.isSelected) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.content,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: null,
        );

        textPainter.layout(
          minWidth: 0,
          maxWidth: element.info.size.width,
        );

        final textOffset = element.info.position;
        textPainter.paint(canvas, textOffset);

        // final textBoxPaint = Paint()
        //   ..color = Colors.black
        //   ..style = PaintingStyle.stroke;

        // final textBoxRect = Rect.fromLTWH(
        //   textOffset.dx,
        //   textOffset.dy,
        //   element.info.size.width,
        //   element.info.size.height,
        // );

        // canvas.drawRect(textBoxRect, textBoxPaint);
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

  // void drawMovableTextBoxes(Canvas canvas, List<MovableTextItem> movableItems) {
  //   for (var item in movableItems) {
  //     final textPainter = TextPainter(
  //       text: TextSpan(
  //         text: item.text,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 16.0,
  //         ),
  //       ),
  //       textDirection: TextDirection.ltr,
  //       maxLines: null,
  //     );

  //     textPainter.layout(
  //       minWidth: 0,
  //       maxWidth: item.info.size.width,
  //     );

  //     final textOffset = item.info.position;
  //     textPainter.paint(canvas, textOffset);

  //     final textBoxPaint = Paint()
  //       ..color = Colors.black
  //       ..style = PaintingStyle.stroke;

  //     final textBoxRect = Rect.fromLTWH(
  //       textOffset.dx,
  //       textOffset.dy,
  //       item.info.size.width,
  //       item.info.size.height,
  //     );

  //     canvas.drawRect(textBoxRect, textBoxPaint);
  //   }
  // }

  @override
  bool shouldRepaint(covariant PagePainter oldDelegate) {
    return true;
  }
}
