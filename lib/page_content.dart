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

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;

    return GestureDetector(
      onPanStart: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath = Path()
            ..moveTo(details.localPosition.dx, details.localPosition.dy);
          // Add new drawing element to the provider
          pageContentProvider.addDrawing(currentPage, currentPath!);
        }
      },
      onPanUpdate: (details) {
        if (currentMode == EditMode.pencil && currentPath != null) {
          setState(() {
            currentPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
            // Update the last drawing element in the provider
            pageContentProvider.updateLastDrawing(currentPage, currentPath!);
          });
        }
      },
      onPanEnd: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath = null;
        }
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
          ),
          // Make sure CustomPaint fills the container
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PagePainter extends CustomPainter {
  final List<DrawingElement> elements;

  _PagePainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    // Sort elements by z-index before painting
    final sortedElements = List<DrawingElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var element in sortedElements) {
      if (element is PencilElement) {
        final paint = Paint()
          ..color = element.isSelected ? Colors.blue : Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        canvas.drawPath(element.path, paint);

        // Draw selection bounds if element is selected
        if (element.isSelected) {
          final boundsPaint = Paint()
            ..color = Colors.blue
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

          canvas.drawRect(element.bounds, boundsPaint);
        }
      }
      // Add other element type handling here as needed
    }
  }

  @override
  bool shouldRepaint(covariant _PagePainter oldDelegate) {
    return true;
  }
}