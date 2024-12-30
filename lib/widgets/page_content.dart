import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movable/movable.dart';
import 'package:provider/provider.dart';
import '../painters/page_painter.dart';
import '../painters/selection_painter.dart';
import '../providers/canvas_provider.dart';
import '../providers/edit_mode_provider.dart';
import '../providers/export_handler_provider.dart';
import '../providers/page_content_provider.dart';
import '../utils/erasor_collision_util_function.dart';
import 'lazer_pointer.dart';

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  Offset? startPoint;
  Offset? currentPoint;
  bool isDrawing = false;
  Path? currentPath;
  Path? eraserPath;
  final double eraserWidth = 20.0;
  final GlobalKey repaintBoundaryKey = GlobalKey();
  TextEditingController textController = TextEditingController();
  // Add movable state variables
  MovableInfo? movableInfo;

  MovableInfo imageMovableInfo = MovableInfo(
    size: const Size(100, 100), // Default size
    position: const Offset(0, 0), // Center of the page will be set later
    rotateAngle: 0,
  );
  @override
  void initState() {
    super.initState();
    Provider.of<ExportHandlerProvider>(context, listen: false)
        .setRepaintBoundaryKey(repaintBoundaryKey);
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;
    void saveMovableContent() {
      if (movableInfo != null) {
        pageContentProvider.addText(currentPage, movableInfo!.rect,
            text: textController.text);
        textController.clear();
      }
      if(pageContentProvider.imageBitMap!=null){
        if (pageContentProvider.imageBitMap != null) {
          final imageBounds = Rect.fromLTWH(
            imageMovableInfo.position.dx,
            imageMovableInfo.position.dy,
            imageMovableInfo.size.width,
            imageMovableInfo.size.height,
          );
          pageContentProvider.addImage(currentPage, pageContentProvider.imageBitMap!, imageBounds);
          pageContentProvider.clearImageBitMap();
        }
      }
      setState(() {
        movableInfo = null;
        imageMovableInfo = MovableInfo(
          size: const Size(100, 100),
          position: const Offset(0, 0),
          rotateAngle: 0,
        );
      });
    }

    void _addMovableTextBox(Offset start, Offset end) {
      final rect = Rect.fromPoints(start, end);
      setState(() {
        movableInfo = MovableInfo(
          size: rect.size,
          position: rect.topLeft,
          rotateAngle: 0,
        );
      });
    }

    return Stack(
      children: [
        // Background container
        RepaintBoundary(
          key: repaintBoundaryKey,
          child: ClipRect( // Ensure nothing goes outside the canvas
            child: Container(
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
        ),

        // Text mode selection area
        if (currentMode == EditMode.text)
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                startPoint = details.localPosition;
                currentPoint = details.localPosition;
                isDrawing = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                currentPoint = details.localPosition;
              });
            },
            onPanEnd: (details) {
              if (startPoint != null && currentPoint != null) {
                _addMovableTextBox(startPoint!, currentPoint!);
                setState(() {
                  startPoint = null;
                  currentPoint = null;
                  isDrawing = false;
                });
              }
            },
            child: CustomPaint(
              painter: SelectionRectanglePainter(
                currentStart: startPoint,
                currentEnd: currentPoint,
                isDrawing: isDrawing,
              ),
              size: Size.infinite,
            ),
          ),

        // Drawing/Eraser gesture layer
        if (currentMode != EditMode.text)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                handleToolStart(
                    details, currentMode, pageContentProvider, currentPage);
              },
              onPanUpdate: (details) {
                handleToolUpdate(
                    details, currentMode, pageContentProvider, currentPage);
              },
              onPanEnd: (_) {
                resetToolState();
              },
              child: Container(color: Colors.transparent),
            ),
          ),

        // Movable text box
        if (movableInfo != null && currentMode == EditMode.text)
          CraftorMovable(
            isSelected: true,
            keepRatio: RawKeyboard.instance.keysPressed
                .contains(LogicalKeyboardKey.shiftLeft),
            scale: 1,
            scaleInfo: movableInfo!,
            onTapInside: () => {},
            onTapOutside: (_) => saveMovableContent(),
            onChange: (newInfo) => setState(() => movableInfo = newInfo),
            child: TextField(
              maxLines: null,
              controller: textController,
              expands: true,
              style: const TextStyle(
                color: Colors.black,
                height: 1,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
        if (pageContentProvider.imageBitMap != null &&
            currentMode == EditMode.image)
          CraftorMovable(
            isSelected: true,
            keepRatio: RawKeyboard.instance.keysPressed
                .contains(LogicalKeyboardKey.shiftLeft),
            scale: 1,
            scaleInfo: imageMovableInfo,
            onTapInside: () => {},
            onTapOutside: (_) => saveMovableContent(),
            onChange: (newInfo) => setState(() => imageMovableInfo = newInfo),
            child: Image.memory(
              pageContentProvider.imageBitMap!,
              fit: BoxFit.cover,
            ),
          ),
        if (currentMode == EditMode.lazer)
          LaserPointer(isActive: currentMode == EditMode.lazer)
      ],
    );
  }

  // ... rest of your methods remain the same
  void handleToolStart(
    DragStartDetails details,
    EditMode? mode,
    PageContentProvider provider,
    int currentPage,
  ) {
    if (mode == EditMode.pencil) {
      currentPath = Path()
        ..moveTo(details.localPosition.dx, details.localPosition.dy);
      provider.addDrawing(currentPage, currentPath!);
    } else if (mode == EditMode.erasor) {
      eraserPath = Path()
        ..moveTo(details.localPosition.dx, details.localPosition.dy);
      final elementsToErase = findElementsToErase(
        details.localPosition,
        provider.getPageElements(currentPage),
        eraserWidth,
      );
      for (var elementId in elementsToErase) {
        provider.removeElement(currentPage, elementId);
      }
    }
  }

  void handleToolUpdate(
    DragUpdateDetails details,
    EditMode? mode,
    PageContentProvider provider,
    int currentPage,
  ) {
    if (mode == EditMode.pencil && currentPath != null) {
      setState(() {
        currentPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
        provider.updateLastDrawing(currentPage, currentPath!);
      });
    } else if (mode == EditMode.erasor && eraserPath != null) {
      setState(() {
        eraserPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
        final elementsToErase = findElementsToErase(
          details.localPosition,
          provider.getPageElements(currentPage),
          eraserWidth,
        );
        for (var elementId in elementsToErase) {
          provider.removeElement(currentPage, elementId);
        }
      });
    }
  }

  void resetToolState() {
    setState(() {
      currentPath = null;
      eraserPath = null;
    });
  }
}
