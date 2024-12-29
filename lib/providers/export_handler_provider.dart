import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExportHandlerProvider extends ChangeNotifier {
  GlobalKey? _repaintBoundaryKey;
  bool _isExporting = false;
  String? _errorMessage;

  // Getters
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;
  
  // Setter for the key
  void setRepaintBoundaryKey(GlobalKey key) {
    _repaintBoundaryKey = key;
  }

  // Reset error message
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Export function
  Future<Uint8List?> exportDrawing({
    double pixelRatio = 3.0,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    if (_repaintBoundaryKey == null) {
      _errorMessage = 'Export key not set';
      notifyListeners();
      return null;
    }

    try {
      _isExporting = true;
      _errorMessage = null;
      notifyListeners();

      // Get the RenderRepaintBoundary object
      final RenderRepaintBoundary? boundary = _repaintBoundaryKey!.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Boundary not found');
      }

      // Convert the boundary to an image
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      
      // Convert image to byte data
      final ByteData? byteData = await image.toByteData(format: format);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      // Convert to Uint8List
      final Uint8List imageBytes = byteData.buffer.asUint8List();
      
      // Clean up
      image.dispose();
      
      _isExporting = false;
      notifyListeners();
      
      return imageBytes;
    } catch (e) {
      _errorMessage = 'Error exporting: ${e.toString()}';
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }
}