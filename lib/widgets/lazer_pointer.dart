import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lazer_point.dart';
import '../painters/lazer_painter.dart';

class LaserPointer extends StatefulWidget {
  final bool isActive;
  final Color laserColor;
  final double strokeWidth;
  final Duration fadeDuration;

  const LaserPointer({
    super.key,
    required this.isActive,
    this.laserColor = Colors.red,
    this.strokeWidth = 3.0,
    this.fadeDuration = const Duration(milliseconds: 500),
  });

  @override
  State<LaserPointer> createState() => _LaserPointerState();
}

class _LaserPointerState extends State<LaserPointer> {
  List<LaserPoint> laserPoints = [];
  Timer? fadeTimer;

  void startLaserFadeTimer() {
    fadeTimer?.cancel();
    fadeTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        laserPoints = laserPoints.where((point) {
          final age = DateTime.now().difference(point.createdAt).inMilliseconds;
          point.opacity = 1.0 - (age / widget.fadeDuration.inMilliseconds);
          return point.opacity > 0;
        }).toList();
      });
      
      if (laserPoints.isEmpty) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    fadeTimer?.cancel();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.isActive) return;
    
    setState(() {
      laserPoints = [LaserPoint(point: details.localPosition)];
    });
    startLaserFadeTimer();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.isActive) return;
    
    setState(() {
      laserPoints.add(LaserPoint(point: details.localPosition));
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    // The fade timer will continue running until all points are faded out
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: LaserPainter(
          points: laserPoints,
          laserColor: widget.laserColor,
          strokeWidth: widget.strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}
