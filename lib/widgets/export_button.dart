import 'dart:io' as io;
import 'dart:typed_data';
import 'package:canvas_app/widgets/split_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/export_handler_provider.dart';
import 'dart:html' as html;

import '../utils/download_utils.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExportHandlerProvider>(
      builder: (context, exportProvider, child) {
        if (exportProvider.isExporting) {
          return const CircularProgressIndicator();
        }

        return SplitButton(
          label: 'Export Page(in PNG)',
          onPressed: () async {
            try {
              final imageBytes = await exportProvider.exportDrawing();
              if (imageBytes != null) {
                final filename =
                    'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
                if (kIsWeb) {
                  webDownload(context, imageBytes, filename);
                } else {
                  await mobileDownload(context, imageBytes, filename);
                }
              } else if (exportProvider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(exportProvider.errorMessage!)),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error during export: $e')),
              );
            }
          },
          menuItems: [
            PopupMenuItem(
              value: 'export_png',
              child: Text('Export File in PNG'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exporting File in PNG...')),
                );
              },
            ),
            PopupMenuItem(
              value: 'export_page_pdf',
              child: Text('Export Page in PDF'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exporting Page in PDF...')),
                );
              },
            ),
            PopupMenuItem(
              value: 'export_file_pdf',
              child: Text('Export File in PDF'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exporting File in PDF...')),
                );
              },
            ),
          ],
        );
      },
    );
  }

}
