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
  // bool isMovableActive = false;
  Path? currentPath;
  Path? eraserPath;
  final double eraserWidth = 20.0;

  movableInfo? activeMovableInfo;
  // List<MovableTextItem> movableItems = [];

  void _onMovableTapInside(movableInfo info) {
    setState(() {
      activeMovableInfo = info;
    });
  }

  void _onMovableTapOutside() {
    setState(() {
      activeMovableInfo = null;
    });
  }

  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set the key in the provider
    Provider.of<ExportHandlerProvider>(context, listen: false)
        .setRepaintBoundaryKey(repaintBoundaryKey);
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;
    void _addMovableTextBox(Offset start, Offset end) {
      final rect = Rect.fromPoints(start, end);
      pageContentProvider.addText(
        currentPage,
        rect,
        text: 'Double click to edit',
      );
    }

    return Stack(
      children: [
        // Background container
        RepaintBoundary(
          key: repaintBoundaryKey,
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

        // Text mode selection area
        if (currentMode == EditMode.text && activeMovableInfo == null)
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

        // Movable text boxes
        // ...movableItems.map((item) {
        //   return CraftorMovable(
        //     isSelected: activeMovableInfo == item.info,
        //     keepRatio: RawKeyboard.instance.keysPressed
        //         .contains(LogicalKeyboardKey.shiftLeft),
        //     scale: 1,
        //     scaleInfo: item.info,
        //     onTapInside: () => _onMovableTapInside(item.info),
        //     onTapOutside: (_) => _onMovableTapOutside(),
        //     onChange: (newInfo) {
        //       setState(() {
        //         final index = movableItems.indexWhere((i) => i.info == item.info);
        //         if (index != -1) {
        //           movableItems[index] = MovableTextItem(
        //             info: newInfo,
        //             text: item.text,
        //           );
        //         }
        //       });
        //     },
        //     child: Container(
        //       width: item.info.size.width,
        //       height: item.info.size.height,
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         border: Border.all(
        //           color: activeMovableInfo == item.info
        //               ? Colors.blue
        //               : Colors.grey.withOpacity(0.5),
        //         ),
        //       ),
        //       child: TextField(
        //         controller: TextEditingController(text: item.text),
        //         maxLines: null,
        //         expands: true,
        //         style: const TextStyle(color: Colors.black),
        //         decoration: const InputDecoration(
        //           contentPadding: EdgeInsets.all(8.0),
        //           border: InputBorder.none,
        //         ),
        //         onChanged: (newText) {
        //           final index = movableItems.indexWhere((i) => i.info == item.info);
        //           if (index != -1) {
        //             setState(() {
        //               movableItems[index] = MovableTextItem(
        //                 info: item.info,
        //                 text: newText,
        //               );
        //             });
        //           }
        //         },
        //       ),
        //     ),
        //   );
        // }).toList(),
        if (currentMode == EditMode.lazer) LaserPointer(isActive: currentMode == EditMode.lazer)
      ],
    );
  }

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

class MovableTextItem {
  final movableInfo info;
  final String text;

  MovableTextItem({
    required this.info,
    required this.text,
  });
}
