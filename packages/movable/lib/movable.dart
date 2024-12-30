// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_field
import 'dart:math';
import 'dart:ui';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';

import '../enums/scale_direction_enum.dart';
import '../helpers/scale_helper.dart';
import 'models/interactive_box_info.dart';
import 'models/scale_info.dart';
export 'models/interactive_box_info.dart';

class CraftorMovable extends StatefulWidget {
  const CraftorMovable({
    super.key,
    required this.isSelected,
    required this.keepRatio,
    required this.scale,
    required this.scaleInfo,
    required this.onTapInside,
    this.onDoubleTap,
    required this.onTapOutside,
    required this.onChange,
    this.onChangeEnd,
    this.onChangeStart,
    this.onSecondaryTapDown,
    required this.child,
  });

  final bool isSelected;
  final bool keepRatio;
  final double scale;
  final MovableInfo scaleInfo;
  final Function()? onDoubleTap;
  final Function() onTapInside;
  final Function(PointerDownEvent e) onTapOutside;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Function(MovableInfo) onChange;
  final Function()? onChangeEnd;
  final Function()? onChangeStart;
  final Widget child;

  @override
  State<CraftorMovable> createState() => _CraftorMovableState();
}

class _CraftorMovableState extends State<CraftorMovable> {
  late double _width;
  late double _height;
  bool isMoving = false;
  double _x = 0.0;
  double _y = 0.0;
  double _startingAngle = 0.0;
  double _prevAngle = 0.0;
  double _finalAngle = 0.0;
  bool isHover = false;

  @override
  void initState() {
    super.initState();
    _updateFromScaleInfo();
  }

  @override
  void didUpdateWidget(CraftorMovable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleInfo != widget.scaleInfo) {
      _updateFromScaleInfo();
    }
  }

  void _updateFromScaleInfo() {
    _x = widget.scaleInfo.position.dx;
    _y = widget.scaleInfo.position.dy;
    _width = widget.scaleInfo.size.width;
    _height = widget.scaleInfo.size.height;
    _finalAngle = widget.scaleInfo.rotateAngle;
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Colors.black;

    return TapRegion(
      onTapInside: (d) => widget.onTapInside(),
      onTapOutside: (d) => widget.onTapOutside(d),
      child: Stack(
        children: [
          Positioned(
            left: _x,
            top: _y,
            width: _width,
            height: _height,
            child: DeferredPointerHandler(
              child: GestureDetector(
                onDoubleTap: widget.onDoubleTap,
                onPanUpdate: widget.isSelected ? _onMoving : null,
                onSecondaryTapDown: widget.onSecondaryTapDown,
                onPanEnd: widget.isSelected
                    ? (d) {
                        setState(() {
                          isMoving = false;
                        });
                        widget.onChangeEnd?.call();
                      }
                    : null,
                onPanStart: widget.isSelected
                    ? (d) {
                        setState(() {
                          isMoving = true;
                        });
                        _onScalingStart();
                      }
                    : null,
                supportedDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
                child: Transform.rotate(
                  angle: _finalAngle,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.passthrough,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: MouseRegion(
                          cursor: widget.isSelected
                              ? SystemMouseCursors.move
                              : SystemMouseCursors.basic,
                          onEnter: (e) => setState(() => isHover = true),
                          onExit: (e) => setState(() => isHover = false),
                          child: Container(
                            width: _width,
                            height: _height,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.isSelected ? borderColor : Colors.transparent,
                                width: 2 / widget.scale,
                              ),
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),
                      if (widget.isSelected) ...[
                        // Only show handles when selected
                        if (!widget.keepRatio) ..._buildNonRatioHandles(borderColor),
                        ..._buildCornerHandles(borderColor),
                        _buildRotationHandle(borderColor),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNonRatioHandles(Color borderColor) {
    return [
      _buildResizeHandle(
        top: -4 / widget.scale,
        left: 0,
        width: _width,
        height: 9 / widget.scale,
        cursor: SystemMouseCursors.resizeUpDown,
        direction: ScaleDirection.topCenter,
      ),
      _buildResizeHandle(
        bottom: -4 / widget.scale,
        left: 0,
        width: _width,
        height: 9 / widget.scale,
        cursor: SystemMouseCursors.resizeUpDown,
        direction: ScaleDirection.bottomCenter,
      ),
      _buildResizeHandle(
        top: 0,
        left: -4 / widget.scale,
        width: 9 / widget.scale,
        height: _height,
        cursor: SystemMouseCursors.resizeLeftRight,
        direction: ScaleDirection.centerLeft,
      ),
      _buildResizeHandle(
        top: 0,
        right: -4 / widget.scale,
        width: 9 / widget.scale,
        height: _height,
        cursor: SystemMouseCursors.resizeLeftRight,
        direction: ScaleDirection.centerRight,
      ),
    ];
  }

  List<Widget> _buildCornerHandles(Color borderColor) {
    return [
      _buildCornerHandle(
        top: -4 / widget.scale,
        left: -4 / widget.scale,
        alignment: Alignment.topLeft,
        direction: ScaleDirection.topLeft,
        borderColor: borderColor,
      ),
      _buildCornerHandle(
        top: -4 / widget.scale,
        right: -4 / widget.scale,
        alignment: Alignment.topRight,
        direction: ScaleDirection.topRight,
        borderColor: borderColor,
      ),
      _buildCornerHandle(
        bottom: -4 / widget.scale,
        left: -4 / widget.scale,
        alignment: Alignment.bottomLeft,
        direction: ScaleDirection.bottomLeft,
        borderColor: borderColor,
      ),
      _buildCornerHandle(
        bottom: -4 / widget.scale,
        right: -4 / widget.scale,
        alignment: Alignment.bottomRight,
        direction: ScaleDirection.bottomRight,
        borderColor: borderColor,
      ),
    ];
  }

  Widget _buildResizeHandle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double width,
    required double height,
    required MouseCursor cursor,
    required ScaleDirection direction,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: DeferPointer(
        child: MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            onPanStart: (d) => _onScalingStart(),
            onPanUpdate: (details) => _onScaling(details, direction),
            onPanEnd: (details) => _onScalingEnd(details),
            supportedDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            child: Container(
              width: width,
              height: height,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerHandle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Alignment alignment,
    required ScaleDirection direction,
    required Color borderColor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: DeferPointer(
        child: GestureDetector(
          onPanStart: (d) => _onScalingStart(),
          onPanUpdate: (details) => _onScaling(details, direction),
          onPanEnd: (details) => _onScalingEnd(details),
          supportedDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
          child: Container(
            width: 9 / widget.scale,
            height: 9 / widget.scale,
            decoration: buildBorder(alignment, borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle(Color borderColor) {
    return Positioned.fill(
      top: -20,
      child: DeferPointer(
        child: GestureDetector(
          onPanStart: (details) {
            _startingAngle = _finalAngle;
          },
          onPanUpdate: (details) {
            final center = Rect.fromLTWH(0, 0, _width, _height).center;
            final newAngle = getAngleFromPoints(center, details.localPosition);
            setState(() {
              _finalAngle = _startingAngle + newAngle + pi / 2;
            });
            widget.onChange(_getCurrentBoxInfo);
          },
          onPanEnd: (details) {
            _prevAngle = _finalAngle;
            widget.onChange(_getCurrentBoxInfo);
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(height: 20, width: 2, color: borderColor),
              MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  width: 9,
                  height: 9,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                    border: Border.all(width: 1.2, color: borderColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rest of the methods remain the same...
  BoxDecoration buildBorder(Alignment alignment, Color borderColor) {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(width: 1.2 / widget.scale, color: borderColor),
    );
  }

  void _onScaling(DragUpdateDetails update, ScaleDirection scaleDirection) {
    if (!widget.isSelected) return;
    
    final ScaleInfo current = ScaleInfo(
      width: _width,
      height: _height,
      x: _x,
      y: _y,
    );
    
    final ScaleInfoOpt scaleInfoOpt = ScaleInfoOpt(
      scaleDirection: scaleDirection,
      dx: update.delta.dx,
      dy: update.delta.dy,
      rotateAngle: _finalAngle,
    );

    final ScaleInfo scaleInfoAfterCalculation = ScaleHelper.getScaleInfo(
      current: current,
      keepAspectRatio: widget.keepRatio,
      options: scaleInfoOpt,
    );

    if (_isWidthUnderscale(scaleInfoAfterCalculation.width) ||
        _isHeightUnderscale(scaleInfoAfterCalculation.height)) {
      return;
    }

    setState(() {
      _width = scaleInfoAfterCalculation.width;
      _height = scaleInfoAfterCalculation.height;
      _x = scaleInfoAfterCalculation.x;
      _y = scaleInfoAfterCalculation.y;
    });

    widget.onChange(_getCurrentBoxInfo);
  }

  bool _isWidthUnderscale(double width) => width <= 0;
  bool _isHeightUnderscale(double height) => height <= 0;

  MovableInfo get _getCurrentBoxInfo => MovableInfo(
        size: Size(_width, _height),
        position: Offset(_x, _y),
        rotateAngle: _finalAngle,
      );

  void _onScalingEnd(DragEndDetails details) {
    if (widget.isSelected) {
      widget.onChangeEnd?.call();
    }
  }

  void _onScalingStart() {
    if (widget.isSelected) {
      widget.onChangeStart?.call();
    }
  }

  void _onMoving(DragUpdateDetails update) {
    if (!widget.isSelected) return;
    
    setState(() {
      _x += update.delta.dx;
      _y += update.delta.dy;
    });

    widget.onChange(_getCurrentBoxInfo);
  }
}

double getAngleFromPoints(Offset point1, Offset point2) {
  return atan2(point2.dy - point1.dy, point2.dx - point1.dx);
}

Offset rotatePoint(Offset point, Offset origin, double angle) {
  final cosTheta = cos(angle * pi / 180);
  final sinTheta = sin(angle * pi / 180);
  final oPoint = point - origin;
  final newX = oPoint.dx * cosTheta - oPoint.dy * sinTheta;
  final newY = oPoint.dx * sinTheta + oPoint.dy * cosTheta;
  return Offset(newX, newY) + origin;
}