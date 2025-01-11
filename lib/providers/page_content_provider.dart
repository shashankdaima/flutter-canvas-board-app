import 'dart:typed_data';

import 'package:canvas_app/models/drawing_elements/ai_intellisense_element.dart';
import 'package:canvas_app/models/drawing_elements/text_element.dart';
import 'package:canvas_app/providers/export_handler_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movable/movable.dart';
import 'package:provider/provider.dart';

import '../models/drawing_elements/drawing_element.dart';
import '../models/drawing_elements/image_element.dart';
import '../models/drawing_elements/pencil_element.dart';
import '../utils/canvas_state_boundaries_util.dart';
import '../utils/debouncer.dart';
import '../utils/download_utils.dart';
import '../utils/intellisense_api.dart';
import '../utils/logger.dart';
import '../widgets/api_loading_widget.dart';
import 'canvas_provider.dart';

class PageContentProvider extends ChangeNotifier {
  BuildContext? _context;
  ApiStatus intellisenseStatus = ApiStatus.success;
  String? errorMessage;
  PageContentProvider();
  List<AiIntellisenseElement> aiIntellisenseElements = [];

  void setContext(BuildContext context) {
    _context = context;
  }

  // Store elements per page
  final Map<int, List<DrawingElement>> _pageElements = {};
  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 5000));

  // Counter for generating z-indices per page
  final Map<int, int> _zIndexCounters = {};

  Uint8List? _imageBitMap;

  Uint8List? get imageBitMap => _imageBitMap;

  void startIntellisense() {
    if (_context == null) return;
    _debouncer.run(() async {
      intellisenseStatus = ApiStatus.loading;
      notifyListeners();
      final exportProvider =
          Provider.of<ExportHandlerProvider>(_context!, listen: false);
      final imageBytes = await exportProvider.exportDrawing();
      final metaJson = getCanvasJsonData(_context!);
      if (imageBytes != null) {
        try {
          final result = await IntellisenseApi.solve(
              file: imageBytes, canvasData: metaJson);
          intellisenseStatus = ApiStatus.success;
          errorMessage = null;
          final List<dynamic> resultsList = result['results'] ?? [];
          aiIntellisenseElements = resultsList.map((item) => AiIntellisenseElement.fromJson(item)).toList();
          notifyListeners();
          return;
        } catch (e) {
          intellisenseStatus = ApiStatus.error;
          errorMessage = e.toString();
          notifyListeners();
          return;
        }

      } else if (exportProvider.errorMessage != null && _context != null) {
        intellisenseStatus = ApiStatus.error;
        errorMessage = exportProvider.errorMessage!;
        notifyListeners();
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(content: Text(exportProvider.errorMessage!)),
        );
      }
    });
  }

  void setImageBitMap(Uint8List? image) {
    _imageBitMap = image;
    notifyListeners();
  }

  void clearImageBitMap() {
    _imageBitMap = null;
    notifyListeners();
  }

  // Get all elements for a page
  List<DrawingElement> getPageElements(int pageIndex) {
    final elements = _pageElements.putIfAbsent(pageIndex, () => []);
    // print('Page $pageIndex has ${elements.length} elements.');
    return elements;
  }

  // Get next z-index for a page
  int _getNextZIndex(int pageIndex) {
    return _zIndexCounters.update(pageIndex, (value) => value + 1,
        ifAbsent: () => 0);
  }

  // Add a new drawing element
  void addDrawing(int pageIndex, Path path) {
    startIntellisense();
    final bounds = path.getBounds();
    final zIndex = _getNextZIndex(pageIndex);

    final element = PencilElement(
      path: path,
      zIndex: zIndex,
      bounds: bounds,
    );

    _pageElements.putIfAbsent(pageIndex, () => []).add(element);

    // Sort elements by z-index after adding
    _pageElements[pageIndex]?.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    notifyListeners();
  }

  void addText(int pageIndex, Rect bounds, double rotateAngle, {String? text}) {
    startIntellisense();
    final zIndex = _getNextZIndex(pageIndex);

    // Create a text element with the given bounds and text
    final element = TextElement(
        content: text ?? '',
        zIndex: zIndex,
        bounds: bounds,
        angle: rotateAngle,
        isSelected: false);

    _pageElements.putIfAbsent(pageIndex, () => []).add(element);

    // Sort elements by z-index after adding
    _pageElements[pageIndex]?.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    notifyListeners();
  }

  void addImage(int pageIndex, Uint8List imageData, Rect bounds, double angle) {
    startIntellisense();
    final zIndex = _getNextZIndex(pageIndex);

    // Create an image element with the given bounds and image data
    final element = ImageElement(
        imageProvider: MemoryImage(imageData),
        zIndex: zIndex,
        bounds: bounds,
        isSelected: false,
        angle: angle);

    _pageElements.putIfAbsent(pageIndex, () => []).add(element);

    // Sort elements by z-index after adding
    _pageElements[pageIndex]?.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    notifyListeners();
  }

  // Get element by ID
  DrawingElement? getElementById(int pageIndex, String elementId) {
    final elements = getPageElements(pageIndex);
    return elements.cast<DrawingElement?>().firstWhere(
          (element) => element?.id == elementId,
          orElse: () => null,
        );
  }

  // Select a single element
  void selectElement(int pageIndex, String elementId) {
    final elements = getPageElements(pageIndex);

    // Deselect all elements
    for (var element in elements) {
      element.isSelected = false;
    }

    // Select the target element
    final targetElement = getElementById(pageIndex, elementId);
    if (targetElement != null) {
      targetElement.isSelected = true;
      notifyListeners();
    }
  }

  // Update element z-index
  void updateElementZIndex(int pageIndex, String elementId, int newZIndex) {
    final elements = getPageElements(pageIndex);
    final elementIndex = elements.indexWhere((e) => e.id == elementId);

    if (elementIndex != -1) {
      final updatedElement = elements[elementIndex].copyWith(zIndex: newZIndex);
      elements[elementIndex] = updatedElement;
      elements.sort((a, b) => a.zIndex.compareTo(b.zIndex));
      notifyListeners();
    }
  }

  // Update last drawing element
  void updateLastDrawing(int pageIndex, Path path) {
    final elements = getPageElements(pageIndex);
    if (elements.isNotEmpty && elements.last is PencilElement) {
      final bounds = path.getBounds();
      final updatedElement = PencilElement(
        id: elements.last.id,
        path: path,
        zIndex: elements.last.zIndex,
        bounds: bounds,
        isSelected: elements.last.isSelected,
      );

      elements[elements.length - 1] = updatedElement;
      notifyListeners();
    }
  }

  // Clear page elements
  void clearPage(int pageIndex) {
    startIntellisense();
    _pageElements[pageIndex]?.clear();
    _zIndexCounters[pageIndex] = 0;
    notifyListeners();
  }

  // Clear all pages
  void clearAllPages() {
    startIntellisense();
    _pageElements.clear();
    _zIndexCounters.clear();
    notifyListeners();
  }

  void removeElement(int pageIndex, String elementId) {
    final elements = getPageElements(pageIndex);
    elements.removeWhere((element) => element.id == elementId);
    notifyListeners();
    startIntellisense();
  }
}
