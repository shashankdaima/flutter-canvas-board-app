import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 0;
  double currentZoom = 1.0;
  final List<String> pages = ['Page 1'];
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      // Get scale from transformation matrix
      final scale = _transformationController.value.getMaxScaleOnAxis();
      setState(() {
        currentZoom = scale;
      });
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void addNewPage() {
    setState(() {
      pages.add('Page ${pages.length + 1}');
      currentPage = pages.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Main Canvas Area with centered fixed aspect ratio
          Center(
            child: PageView.builder(
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: _transformationController,
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
              child: Row(
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
                      '${(currentZoom * 100).toInt()}%',
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
              ),
            ),
          ),

          // Rest of the widgets remain the same...
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentPage + 1} / ${pages.length}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: currentPage < pages.length - 1
                          ? () {
                              setState(() {
                                currentPage++;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: addNewPage,
                    ),
                  ],
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
    );
  }
}