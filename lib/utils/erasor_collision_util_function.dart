import "package:flutter/material.dart";

import "../models/drawing_elements/drawing_element.dart";
import "../models/drawing_elements/pencil_element.dart";

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
    }
  }

  return elementsToErase;
}
