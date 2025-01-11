import 'package:flutter/material.dart';
import 'drawing_element.dart';
import '../../enums/drawing_element_type.dart';

class AiIntellisenseElement extends DrawingElement {
  final String expression;
  final String type;
  final String explanation;
  final num result;
  final Map<String, double> bbox;
  final List<double> outputPosition;

  AiIntellisenseElement({
    required super.zIndex,
    required super.bounds,
    required this.expression,
    required this.type,
    required this.explanation,
    required this.result,
    required this.bbox,
    required this.outputPosition,
    super.isSelected,
    super.id,
  }) : super(elementType: DrawingElementType.aiIntellisense);

  @override
  AiIntellisenseElement copyWith({
    int? zIndex,
    Rect? bounds,
    bool? isSelected,
    String? expression,
    String? type,
    String? explanation,
    num? result,
    Map<String, double>? bbox,
    List<double>? outputPosition,
  }) {
    return AiIntellisenseElement(
      zIndex: zIndex ?? this.zIndex,
      bounds: bounds ?? this.bounds,
      isSelected: isSelected ?? this.isSelected,
      expression: expression ?? this.expression,
      type: type ?? this.type,
      explanation: explanation ?? this.explanation,
      result: result ?? this.result,
      bbox: bbox ?? this.bbox,
      outputPosition: outputPosition ?? this.outputPosition,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zIndex': zIndex,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'type': type,
      'expression': expression,
      'explanation': explanation,
      'result': result,
      'bbox': bbox,
      'outputPosition': outputPosition,
      'isSelected': isSelected,
    };
  }

  factory AiIntellisenseElement.fromJson(Map<String, dynamic> json) {
    return AiIntellisenseElement(
      zIndex: 0, // Default value, adjust as needed
      bounds: Rect.fromLTWH(
        json['bbox']['x'],
        json['bbox']['y'],
        json['bbox']['width'],
        json['bbox']['height'],
      ),
      expression: json['expression'],
      type: json['type'],
      explanation: json['explanation'],
      result: json['result'],
      bbox: Map<String, double>.from(json['bbox']),
      outputPosition: List<double>.from(json['output_position']),
      isSelected: false,
    );
  }
}
