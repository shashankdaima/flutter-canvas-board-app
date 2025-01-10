import 'package:canvas_app/enums/drawing_element_type.dart';
import 'package:flutter/material.dart';
import 'drawing_element.dart';
import 'package:movable/movable.dart';

class TextElement extends DrawingElement {
  final String content;
  final MovableInfo info;

  TextElement({
    required this.content,
    required super.zIndex,
    required super.bounds,
    required double angle,
    super.id,
    super.isSelected,
  })  : info = MovableInfo(
          size: Size(bounds.width, bounds.height),
          position: Offset(bounds.left, bounds.top),
          rotateAngle: angle,
        ),
        super(type: DrawingElementType.text);

  @override
  TextElement copyWith({
    int? zIndex,
    Rect? bounds,
    bool? isSelected,
    double? angle,
  }) {
    return TextElement(
      content: content,
      zIndex: zIndex ?? this.zIndex,
      bounds: bounds ?? this.bounds,
      angle: angle ?? info.rotateAngle,
      id: id,
      isSelected: isSelected ?? this.isSelected,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'id': id,
      'zIndex': zIndex,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'isSelected': isSelected,
      'content': content,
      'angle': info.rotateAngle,
    };
  }

}
