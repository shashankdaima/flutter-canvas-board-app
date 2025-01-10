// canvas_provider.dart
import 'package:flutter/material.dart';

class CanvasState extends ChangeNotifier {
  int _currentPage = 0;
  double _currentZoom = 1.0;
  final List<String> _pages = ['Page 1'];
  final TransformationController transformationController =
      TransformationController();

  // Getters
  int get currentPage => _currentPage;
  double get currentZoom => _currentZoom;
  List<String> get pages => _pages;
  int get pageCount => _pages.length;
  Size get canvasSize => _canvasSize;
  Size _canvasSize = const Size(0, 0);

  CanvasState() {
    // Listen to transformation changes
    transformationController.addListener(_updateZoom);
  }

  void _updateZoom() {
    _currentZoom = transformationController.value.getMaxScaleOnAxis();
    notifyListeners();
  }

  void setCurrentPage(int page) {
    if (page >= 0 && page < _pages.length) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void addNewPage() {
    _pages.add('Page ${_pages.length + 1}');
    _currentPage = _pages.length - 1;
    notifyListeners();
  }

  void removePage(int index) {
    if (index >= 0 && index < _pages.length) {
      _pages.removeAt(index);
      if (_currentPage >= _pages.length) {
        _currentPage = _pages.length - 1;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    transformationController.removeListener(_updateZoom);
    transformationController.dispose();
    super.dispose();
  }
  void setCanvasSize(Size size) {
    _canvasSize = size;
  }
}
