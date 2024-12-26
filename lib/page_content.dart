import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'canvas_provider.dart';
import 'edit_mode_provider.dart';
import 'page_content_provider.dart';

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  Path? currentPath;

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;

    return GestureDetector(
      onPanStart: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath = Path()
            ..moveTo(details.localPosition.dx, details.localPosition.dy);
          // Create a copy of the path to store in the provider
          pageContentProvider.addDrawing(
            currentPage, 
            Path()..addPath(currentPath!, Offset.zero)
          );
        }
      },
      onPanUpdate: (details) {
        if (currentMode == EditMode.pencil && currentPath != null) {
          setState(() {
            currentPath!.lineTo(details.localPosition.dx, details.localPosition.dy);
            // Update the last path in the provider with the new points
            pageContentProvider.updateLastDrawing(
              currentPage, 
              Path()..addPath(currentPath!, Offset.zero)
            );
          });
        }
      },
      onPanEnd: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath = null;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _PagePainter(pageContentProvider.getPageDrawings(currentPage)),
        ),
      ),
    );
  }
}

class _PagePainter extends CustomPainter {
  final List<Path> paths;

  _PagePainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}