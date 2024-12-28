import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movable/movable.dart';
import 'package:canvas_app/painters/selection_painter.dart';

class DrawableArea extends StatefulWidget {
  const DrawableArea({super.key});

  @override
  State<DrawableArea> createState() => _DrawableAreaState();
}

class _DrawableAreaState extends State<DrawableArea> {
  Offset? startPoint;
  Offset? currentPoint;
  bool isDrawing = false;
  bool isMovableActive = false;

  movableInfo? activeMovableInfo;

  List<movableInfo> movableItems = [];

  void _printRectangleInfo(Offset start, Offset end) {
    final rect = Rect.fromPoints(start, end);
    setState(() {
      movableItems.add(
        movableInfo(
          size: Size(rect.width, rect.height),
          position: Offset(rect.left, rect.top),
          rotateAngle: 0,
        ),
      );
    });
  }

  void _onMovableTapInside(movableInfo info) {
    setState(() {
      isMovableActive = true;
      activeMovableInfo = info;
    });
  }

  void _onMovableTapOutside() {
    setState(() {
      isMovableActive = false;
      activeMovableInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
        // Canvas Drawing Area
        if (!isMovableActive)
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
                _printRectangleInfo(startPoint!, currentPoint!);
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

        // Display Movable Text Boxes
        ...movableItems.map((info) {
          return CraftorMovable(
            isSelected: activeMovableInfo == info,
            keepRatio: RawKeyboard.instance.keysPressed
                .contains(LogicalKeyboardKey.shiftLeft),
            scale: 1,
            scaleInfo: info,
            onTapInside: () => _onMovableTapInside(info),
            onTapOutside: (_) => _onMovableTapOutside(),
            onChange: (newInfo) {
              setState(() {
                final index = movableItems.indexOf(info);
                if (index != -1) {
                  movableItems[index] = newInfo;
                }
              });
            },
            child: Container(
              width: info.size.width,
              height: info.size.height,
              color: Colors.amber,
              // child: const TextField(
              //   maxLines: null,
              //   expands: true,
              //   style: TextStyle(color: Colors.black),
              //   decoration: InputDecoration(
              //     contentPadding: EdgeInsets.all(8.0),
              //     border: InputBorder.none,
              //   ),
              // ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
