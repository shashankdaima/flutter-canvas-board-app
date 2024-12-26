import 'package:flutter/material.dart';

class PageContentProvider extends ChangeNotifier {
  final Map<int, List<Path>> _pageDrawings = {}; // Stores paths per page

  List<Path> getPageDrawings(int pageIndex) {
    return _pageDrawings.putIfAbsent(pageIndex, () => []);
  }

  void addDrawing(int pageIndex, Path path) {
    _pageDrawings.putIfAbsent(pageIndex, () => []).add(path);
    notifyListeners();
  }

  void clearPageDrawings(int pageIndex) {
    _pageDrawings[pageIndex]?.clear();
    notifyListeners();
  }

  void clearAllPages() {
    _pageDrawings.clear();
    notifyListeners();
  }

  void updateLastDrawing(int page, Path path) {
    if (_pageDrawings[page]?.isNotEmpty ?? false) {
      _pageDrawings[page]!.last = path;
      notifyListeners();
    }
  }
}
