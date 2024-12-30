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
}
