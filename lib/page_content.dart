import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'canvas_provider.dart';
import 'edit_mode_provider.dart';
import 'page_content_provider.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    final pageContentProvider = Provider.of<PageContentProvider>(context);
    final currentPage = Provider.of<CanvasState>(context).currentPage;

    Path currentPath = Path();

    return GestureDetector(
      onPanStart: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath = Path();
          currentPath.moveTo(details.localPosition.dx, details.localPosition.dy);
        }
      },
      onPanUpdate: (details) {
        if (currentMode == EditMode.pencil) {
          currentPath.lineTo(details.localPosition.dx, details.localPosition.dy);
          pageContentProvider.addDrawing(currentPage, currentPath);
        }
      },
      onPanEnd: (details) {
        if (currentMode == EditMode.pencil) {
          // Optionally handle path completion here
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
