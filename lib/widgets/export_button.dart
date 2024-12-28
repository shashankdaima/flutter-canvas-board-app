import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/export_handler_provider.dart';
import 'dart:html' as html;
class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExportHandlerProvider>(
      builder: (context, exportProvider, child) {
        if (exportProvider.isExporting) {
          return const CircularProgressIndicator();
        }

        return ElevatedButton(
          onPressed: () async {
            final imageBytes = await exportProvider.exportDrawing();
            if (imageBytes != null) {
              final filename = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
              if (kIsWeb) {
                _webDownload(imageBytes, filename);
              } else {
                await _mobileDownload(imageBytes, filename);
              }
            } else if (exportProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(exportProvider.errorMessage!)),
              );
            }
          },
          child: const Text('Export'),
        );
      },
    );
  }

  void _webDownload(Uint8List bytes, String filename) {
    // Create blob
    final blob = html.Blob([bytes], 'image/png');
    
    // Create download URL
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create anchor element
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    
    // Add to document
    html.document.body?.children.add(anchor);
    
    // Trigger download
    anchor.click();
    
    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _mobileDownload(Uint8List bytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
      // You might want to add platform-specific success notifications here
    } catch (e) {
      print('Error saving file: $e');
      // Handle error appropriately for your app
    }
  }
}