// home.dart
import 'dart:convert';
import 'dart:io';

import 'package:canvas_app/providers/edit_mode_provider.dart';
import 'package:canvas_app/utils/canvas_state_boundaries_util.dart';
import 'package:canvas_app/widgets/export_button.dart';
import 'package:canvas_app/widgets/page_content.dart';
import 'package:canvas_app/providers/page_content_provider.dart';
import 'package:canvas_app/widgets/split_button.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../config.dart';

import '../providers/canvas_provider.dart';
import '../utils/download_utils.dart';
import '../utils/image_upload_handler.dart';
import 'api_loading_widget.dart';

final logger = Logger();

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                      transformationController:
                          canvasState.transformationController,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.1,
                      maxScale: 5.0,
                      panEnabled:
                          Provider.of<EditModeProvider>(context).currentMode ==
                              null,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.height * (4 / 3),
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: AspectRatio(
                              aspectRatio: 4 / 3, child: PageContent()),
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
                      ApiLoadingWidget(
                          status: ApiStatus.loading,
                          errorMessage: 'Failed to connect to server'),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
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
                      const ExportButton(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              ? () => canvasState
                                  .setCurrentPage(canvasState.currentPage - 1)
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
                          onPressed: canvasState.currentPage <
                                  canvasState.pageCount - 1
                              ? () => canvasState
                                  .setCurrentPage(canvasState.currentPage + 1)
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
              child: Consumer<EditModeProvider>(
                builder: (context, editModeProvider, _) {
                  return Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.circle,
                          color: Colors.red,
                        ),
                        tooltip: 'Lazer',
                        color: editModeProvider.currentMode == EditMode.lazer
                            ? theme.colorScheme.primary
                            : null,
                        onPressed: () {
                          if (editModeProvider.currentMode == EditMode.lazer) {
                            editModeProvider.setMode(null);
                          } else {
                            editModeProvider.setMode(EditMode.lazer);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (editModeProvider.currentMode ==
                                  EditMode.lazer) {
                                return Colors.red.shade900;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Pencil',
                        color: editModeProvider.currentMode == EditMode.pencil
                            ? theme.colorScheme.primary
                            : null,
                        onPressed: () {
                          if (editModeProvider.currentMode == EditMode.pencil) {
                            editModeProvider.setMode(null);
                          } else {
                            editModeProvider.setMode(EditMode.pencil);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (editModeProvider.currentMode ==
                                  EditMode.pencil) {
                                return Colors.grey.shade900;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cleaning_services),
                        tooltip: 'Erasor',
                        color: editModeProvider.currentMode == EditMode.erasor
                            ? theme.colorScheme.primary
                            : null,
                        onPressed: () {
                          if (editModeProvider.currentMode == EditMode.erasor) {
                            editModeProvider.setMode(null);
                          } else {
                            editModeProvider.setMode(EditMode.erasor);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (editModeProvider.currentMode ==
                                  EditMode.erasor) {
                                return Colors.grey.shade900;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields),
                        tooltip: 'Text',
                        color: editModeProvider.currentMode == EditMode.text
                            ? theme.colorScheme.primary
                            : null,
                        onPressed: () {
                          if (editModeProvider.currentMode == EditMode.text) {
                            editModeProvider.setMode(null);
                          } else {
                            editModeProvider.setMode(EditMode.text);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (editModeProvider.currentMode ==
                                  EditMode.text) {
                                return Colors.grey.shade900;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        tooltip: 'Image',
                        color: editModeProvider.currentMode == EditMode.image
                            ? theme.colorScheme.primary
                            : null,
                        onPressed: () async {
                          if (editModeProvider.currentMode == EditMode.image) {
                            editModeProvider.setMode(null);
                          } else {
                            editModeProvider.setMode(EditMode.image);
                            // Handle image upload
                            final imageBytes =
                                await ImageUploadHandler.pickImage(context);
                            if (imageBytes != null) {
                              // Add the image to your canvas or page content
                              Provider.of<PageContentProvider>(context,
                                      listen: false)
                                  .setImageBitMap(imageBytes);
                            } else {
                              editModeProvider.setMode(EditMode.image);
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (editModeProvider.currentMode ==
                                  EditMode.image) {
                                return Colors.grey.shade900;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      if (DEBUG_STATE)
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Generate JSON',
                          onPressed: () {
                            final jsonData = getCanvasJsonData(context);
                            jsonDownload(context, jsonData, 'canvas');
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
