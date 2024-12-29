import 'package:flutter/material.dart';

class LaserPoint {
  final Offset point;
  double opacity;
  final DateTime createdAt;

  LaserPoint({
    required this.point,
    this.opacity = 1.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
