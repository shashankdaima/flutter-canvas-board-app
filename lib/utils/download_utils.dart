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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/export_handler_provider.dart';
import '../utils/download_utils.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

void webDownload(BuildContext context, Uint8List bytes, String filename) {
  try {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during web download: $e')),
    );
  }
}

Future<void> mobileDownload(
    BuildContext context, Uint8List bytes, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = io.File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving file: $e')),
    );
  }
}

Future<void> mobileDownloadPDF(
    BuildContext context, List<Uint8List> images, String filename) async {
  final pdf = pw.Document();

  for (var imageBytes in images) {
    final image = pw.MemoryImage(imageBytes);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );
  }

  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename';
  final file = io.File(filePath);
  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('PDF saved at: $filePath')),
  );
}

Future<void> webDownloadPDF(
    BuildContext context, List<Uint8List> images, String filename) async {
  // Create PDF document
  final pdf = pw.Document();

  // Add pages with images
  for (var imageBytes in images) {
    try {
      final image = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: ${e.toString()}')),
      );
      return;
    }
  }

  try {
    // Generate PDF bytes
    final bytes = await pdf.save();
    // Use a Future to handle the download process asynchronously
    await Future.microtask(() {
      // Create blob and URL
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Trigger download
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = filename.endsWith('.pdf') ? filename : '$filename.pdf';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      // Clean up
      html.Url.revokeObjectUrl(url);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF downloaded successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
    );
  }
}
