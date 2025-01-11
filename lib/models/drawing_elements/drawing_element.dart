import 'package:flutter/material.dart';

import '../../enums/drawing_element_type.dart';

abstract class DrawingElement {
  final String id;
  final int zIndex;
  final Rect bounds;
  final DrawingElementType elementType;
  bool isSelected;

  DrawingElement({
    String? id,
    required this.zIndex,
    required this.bounds,
    required this.elementType,
    this.isSelected = false,
  }) : id = id ?? UniqueKey().toString();

  DrawingElement copyWith({
    int? zIndex,
    Rect? bounds,
    bool? isSelected,
  });
  Map<String, dynamic> toJson();

}

