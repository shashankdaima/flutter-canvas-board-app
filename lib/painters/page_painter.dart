import 'package:canvas_app/models/drawing_elements/image_element.dart';
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
      if (element is TextElement && !element.isSelected) {
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

        // Save the current canvas state
        canvas.save();

        // Translate to the center of the text box
        final textCenter = element.info.position + Offset(element.info.size.width / 2, element.info.size.height / 2);
        canvas.translate(textCenter.dx, textCenter.dy);

        // Rotate the canvas by 90 degrees (right angle)
        canvas.rotate(element.info.rotateAngle);

        // Translate back by half of the text box size
        canvas.translate(-textCenter.dx, -textCenter.dy);

        // Paint the text
        textPainter.paint(canvas, element.info.position);

        // Restore the canvas to its previous state
        canvas.restore();

        // final textBoxPaint = Paint()
        //   ..color = Colors.black
        //   ..style = PaintingStyle.stroke;

        // final textBoxRect = Rect.fromLTWH(
        //   element.info.position.dx,
        //   element.info.position.dy,
        //   element.info.size.width,
        //   element.info.size.height,
        // );

        // canvas.drawRect(textBoxRect, textBoxPaint);
      }
      if (element is ImageElement && !element.isSelected) {
        final imageRect = element.bounds;
        final paint = Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.fill;

        canvas.drawRect(imageRect, paint);

        final image = element.imageProvider.resolve(ImageConfiguration());
        image.addListener(ImageStreamListener((ImageInfo info, bool _) {
          final imageSize =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
          final srcRect = Offset.zero & imageSize;
          final dstRect = imageRect;

          // Calculate the scale to cover the destination rectangle
          final scale = (dstRect.width / srcRect.width).clamp(
              dstRect.height / srcRect.height, double.infinity);

          final scaledSrcWidth = srcRect.width * scale;
          final scaledSrcHeight = srcRect.height * scale;

          final srcOffsetX = (scaledSrcWidth - dstRect.width) / 2;
          final srcOffsetY = (scaledSrcHeight - dstRect.height) / 2;

          final coverSrcRect = Rect.fromLTWH(
            srcOffsetX,
            srcOffsetY,
            dstRect.width / scale,
            dstRect.height / scale,
          );

          // Save the current canvas state
          canvas.save();

          // Translate to the center of the imageRect
          canvas.translate(dstRect.center.dx, dstRect.center.dy);

          // Rotate the canvas by the element's angle
          canvas.rotate(element.angle);

          // Translate back by half of the imageRect size
          canvas.translate(-dstRect.center.dx, -dstRect.center.dy);

          // Draw the image with rotation
          canvas.drawImageRect(info.image, coverSrcRect, dstRect, Paint());

          // Restore the canvas to its previous state
          canvas.restore();
        }));
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
