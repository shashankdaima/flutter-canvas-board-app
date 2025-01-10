import 'package:flutter/material.dart';

import '../../enums/drawing_element_type.dart';
import 'drawing_element.dart';

class ImageElement extends DrawingElement {
  final ImageProvider imageProvider;
  final double angle;

  ImageElement({
    required this.imageProvider,
    required super.zIndex,
    required super.bounds,
    required this.angle,
    super.id,
    super.isSelected,
  }) : super(type: DrawingElementType.image);

  @override
  ImageElement copyWith({
    int? zIndex,
    Rect? bounds,
    bool? isSelected,
    double? angle,
  }) {
    return ImageElement(
      id: id,
      imageProvider: imageProvider,
      zIndex: zIndex ?? this.zIndex,
      bounds: bounds ?? this.bounds,
      isSelected: isSelected ?? this.isSelected,
      angle: angle ?? this.angle,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      'type': 'image',
      'id': id,
      'zIndex': zIndex,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'isSelected': isSelected,
      'angle': angle,
    };
  }
}
