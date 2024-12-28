import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../painters/page_painter.dart';
import '../providers/canvas_provider.dart';
import '../providers/edit_mode_provider.dart';
import '../models/drawing_elements/drawing_element.dart';
import '../models/drawing_elements/pencil_element.dart';
import '../providers/page_content_provider.dart';
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
          behavior: HitTestBehavior.translucent,
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
              painter: PagePainter(
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
