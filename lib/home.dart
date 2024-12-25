// home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'canvas_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider(
      create: (_) => CanvasState(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Stack(
          children: [
            // Main Canvas Area
            Center(
              child: Consumer<CanvasState>(
                builder: (context, canvasState, _) {
                  return PageView.builder(
                    itemCount: canvasState.pageCount,
                    onPageChanged: canvasState.setCurrentPage,
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        transformationController: canvasState.transformationController,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: 0.1,
                        maxScale: 5.0,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.height * (4/3),
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
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
                                child: Center(
                                  child: Text(
                                    'Drawing Area',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Top Toolbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: theme.colorScheme.surface.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
                child: Consumer<CanvasState>(
                  builder: (context, canvasState, _) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            // Toggle sidebar
                          },
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(canvasState.currentZoom * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                          onPressed: () {
                            // Handle export
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Bottom Page Controls
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Consumer<CanvasState>(
                    builder: (context, canvasState, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left),
                            onPressed: canvasState.currentPage > 0
                                ? () => canvasState.setCurrentPage(canvasState.currentPage - 1)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${canvasState.currentPage + 1} / ${canvasState.pageCount}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: canvasState.currentPage < canvasState.pageCount - 1
                                ? () => canvasState.setCurrentPage(canvasState.currentPage + 1)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: canvasState.addNewPage,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Right Toolbar
            Positioned(
              top: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Pencil',
                      onPressed: () {
                        // Select pencil tool
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.text_fields),
                      tooltip: 'Text',
                      onPressed: () {
                        // Select text tool
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.image),
                      tooltip: 'Image',
                      onPressed: () {
                        // Select image tool
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shape_line),
                      tooltip: 'Shape',
                      onPressed: () {
                        // Select shape tool
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}