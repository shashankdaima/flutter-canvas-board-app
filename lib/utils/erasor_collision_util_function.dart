import "package:flutter/material.dart";

import "../models/drawing_elements/drawing_element.dart";
import "../models/drawing_elements/image_element.dart";
import "../models/drawing_elements/pencil_element.dart";
import "../models/drawing_elements/text_element.dart";

// Helper method to check if a point is near a path
bool isPointNearPath(Offset point, Path path, double threshold) {
  final metrics = path.computeMetrics();
  for (var metric in metrics) {
    for (double t = 0; t <= metric.length; t += 5) {
      final tangent = metric.getTangentForOffset(t);
      if (tangent != null) {
        final distance = (tangent.position - point).distance;
        if (distance < threshold) {
          return true;
        }
      }
    }
  }
  return false;
}

// Helper method to find elements to erase
List<String> findElementsToErase(
    Offset point, List<DrawingElement> elements, double eraserWidth) {
  final elementsToErase = <String>[];

  for (var element in elements) {
    if (element is PencilElement) {
      if (isPointNearPath(point, element.path, eraserWidth / 2)) {
        elementsToErase.add(element.id);
      }
    } else if (element is ImageElement) {
      if (element.bounds.contains(point)) {
        elementsToErase.add(element.id);
      }
    } else if (element is TextElement) {
      final textPainter = TextPainter(
        text: TextSpan(text: element.content, style: TextStyle(fontSize: 16.0)),
        textDirection: TextDirection.ltr,
      )..layout();

      final textBounds = element.bounds;
      final textOffset = Offset(textBounds.left, textBounds.top);

      for (double dx = 0; dx < textPainter.width; dx += 1.0) {
        for (double dy = 0; dy < textPainter.height; dy += 1.0) {
          final textPoint = textOffset + Offset(dx, dy);
          if ((textPoint - point).distance < eraserWidth / 2) {
            elementsToErase.add(element.id);
            break;
          }
        }
      }
    }
  }

  return elementsToErase;
}
