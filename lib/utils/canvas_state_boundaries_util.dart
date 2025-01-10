import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canvas_provider.dart';
import '../providers/page_content_provider.dart';
Map<String, dynamic> getCanvasJsonData(BuildContext context) {
  final pageContentProvider = Provider.of<PageContentProvider>(context, listen: false);
  final currentPage = Provider.of<CanvasState>(context, listen: false).currentPage;
  final pageElements = pageContentProvider
      .getPageElements(currentPage)
      .map((element) => element.toJson())
      .toList();
  final canvasState = Provider.of<CanvasState>(context, listen: false);
  final canvasSize = canvasState.canvasSize;
  
  return {
    'canvasInfo': {
      'width': canvasSize.width,
      'height': canvasSize.height,
    },
    'pageItems': pageElements,
  };
}
