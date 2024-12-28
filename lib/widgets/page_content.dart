import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../painters/page_painter.dart';
import '../providers/canvas_provider.dart';
import '../providers/edit_mode_provider.dart';
import '../models/drawing_elements/drawing_element.dart';
import '../models/drawing_elements/pencil_element.dart';
import '../providers/page_content_provider.dart';
import '../utils/erasor_collision_util_function.dart';

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  Path? currentPath;
  Path? eraserPath;
  final double eraserWidth = 20.0;

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;

    return Stack(
      children: [
        // Background container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        // Drawing canvas layer (no gesture detection)
        RepaintBoundary(
          child: CustomPaint(
            painter: PagePainter(
              elements: pageContentProvider.getPageElements(currentPage),
              eraserPath: currentMode == EditMode.erasor ? eraserPath : null,
              eraserWidth: eraserWidth,
            ),
            size: Size.infinite,
          ),
        ),
        // Separate gesture layer (transparent)
        if (currentMode == EditMode.erasor || currentMode == EditMode.pencil)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  if (currentMode == EditMode.pencil) {
                    currentPath = Path()
                      ..moveTo(
                          details.localPosition.dx, details.localPosition.dy);
                    pageContentProvider.addDrawing(currentPage, currentPath!);
                  } else if (currentMode == EditMode.erasor) {
                    eraserPath = Path()
                      ..moveTo(
                          details.localPosition.dx, details.localPosition.dy);

                    final elementsToErase = findElementsToErase(
                        details.localPosition,
                        pageContentProvider.getPageElements(currentPage),
                        eraserWidth);

                    for (var elementId in elementsToErase) {
                      pageContentProvider.removeElement(currentPage, elementId);
                    }
                  } else if (currentMode == EditMode.text) {
                    eraserPath = Path()
                      ..moveTo(
                          details.localPosition.dx, details.localPosition.dy);
                    pageContentProvider.addText(currentPage, currentPath!);
                  }
                },
                onPanUpdate: (details) {
                  if (currentMode == EditMode.pencil && currentPath != null) {
                    setState(() {
                      currentPath!.lineTo(
                          details.localPosition.dx, details.localPosition.dy);
                      pageContentProvider.updateLastDrawing(
                          currentPage, currentPath!);
                    });
                  } else if (currentMode == EditMode.erasor &&
                      eraserPath != null) {
                    setState(() {
                      eraserPath!.lineTo(
                          details.localPosition.dx, details.localPosition.dy);

                      final elementsToErase = findElementsToErase(
                          details.localPosition,
                          pageContentProvider.getPageElements(currentPage),
                          eraserWidth);

                      for (var elementId in elementsToErase) {
                        pageContentProvider.removeElement(
                            currentPage, elementId);
                      }
                    });
                  }
                },
                onPanEnd: (details) {
                  currentPath = null;
                  eraserPath = null;
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
