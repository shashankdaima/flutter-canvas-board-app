import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'canvas_provider.dart';
import 'edit_mode_provider.dart';
import 'models/drawing_elements/drawing_element.dart';
import 'models/drawing_elements/pencil_element.dart';
import 'providers/page_content_provider.dart';

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  Path? currentPath;
  Path? eraserPath;
  final double eraserWidth = 20.0; // Adjust eraser width as needed

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
  List<String> findElementsToErase(Offset point, List<DrawingElement> elements) {
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

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;

    return Stack(
      children: [
        GestureDetector(
          onPanStart: (details) {
            if (currentMode == EditMode.pencil) {
              currentPath = Path()
                ..moveTo(details.localPosition.dx, details.localPosition.dy);
              pageContentProvider.addDrawing(currentPage, currentPath!);
            } else if (currentMode == EditMode.erasor) {
              eraserPath = Path()
                ..moveTo(details.localPosition.dx, details.localPosition.dy);
              
              // Find and erase elements at the start point
              final elementsToErase = findElementsToErase(
                details.localPosition,
                pageContentProvider.getPageElements(currentPage)
              );
              
              // Remove the elements
              for (var elementId in elementsToErase) {
                pageContentProvider.removeElement(currentPage, elementId);
              }
            }
          },
          onPanUpdate: (details) {
            if (currentMode == EditMode.pencil && currentPath != null) {
              setState(() {
                currentPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
                pageContentProvider.updateLastDrawing(currentPage, currentPath!);
              });
            } else if (currentMode == EditMode.erasor && eraserPath != null) {
              setState(() {
                eraserPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
                
                // Find and erase elements at the current point
                final elementsToErase = findElementsToErase(
                  details.localPosition,
                  pageContentProvider.getPageElements(currentPage)
                );
                
                // Remove the elements
                for (var elementId in elementsToErase) {
                  pageContentProvider.removeElement(currentPage, elementId);
                }
              });
            }
          },
          onPanEnd: (details) {
            currentPath = null;
            eraserPath = null;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _PagePainter(
                elements: pageContentProvider.getPageElements(currentPage),
                eraserPath: currentMode == EditMode.erasor ? eraserPath : null,
                eraserWidth: eraserWidth,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _PagePainter extends CustomPainter {
  final List<DrawingElement> elements;
  final Path? eraserPath;
  final double eraserWidth;

  _PagePainter({
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
  bool shouldRepaint(covariant _PagePainter oldDelegate) {
    return true;
  }
}