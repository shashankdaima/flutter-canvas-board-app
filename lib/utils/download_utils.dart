import 'dart:convert';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:ui' as ui;
// Data class for PDF generation
class PDFGenerationData {
  final List<Uint8List> images;
  PDFGenerationData(this.images);
}

// Isolate function for PDF generation

Future<Uint8List> _generatePDF(PDFGenerationData data) async {
  final pdf = pw.Document();
  
  for (var imageBytes in data.images) {
    // Decode image to get dimensions
    final image = pw.MemoryImage(imageBytes);
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    
    // Create custom page format based on image dimensions
    final customPageFormat = PdfPageFormat(
      frameInfo.image.width.toDouble(),
      frameInfo.image.height.toDouble(),
      marginAll: 0, // Remove margins
    );
    
    pdf.addPage(
      pw.Page(
        pageFormat: customPageFormat,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );
  }
  
  return pdf.save();
}


// Web download function
Future<void> webDownload(BuildContext context, Uint8List bytes, String filename) async {
  try {
    // Use compute for lightweight operations
    await compute<Map<String, dynamic>, void>(
      (message) {
        final bytes = message['bytes'] as Uint8List;
        final filename = message['filename'] as String;
        
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
        
        return;
      },
      {'bytes': bytes, 'filename': filename},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during web download: $e')),
    );
  }
}
Future<void> jsonDownload(BuildContext context, dynamic data, String filename) async {
  try {
    final jsonString = json.encode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    await compute<Map<String, dynamic>, void>(
      (message) {
        final bytes = message['bytes'] as Uint8List;
        final filename = message['filename'] as String;
        
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = filename.endsWith('.json') ? filename : '$filename.json';
        
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      },
      {'bytes': bytes, 'filename': filename},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during JSON download: $e')),
    );
  }
}


// Mobile download function
Future<void> mobileDownload(
    BuildContext context, Uint8List bytes, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    
    // Use compute for file operations
    await compute<Map<String, dynamic>, void>(
      (message) async {
        final bytes = message['bytes'] as Uint8List;
        final filePath = message['filePath'] as String;
        
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);
      },
      {'bytes': bytes, 'filePath': filePath},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving file: $e')),
    );
  }
}

// Mobile PDF download function
Future<void> mobileDownloadPDF(
    BuildContext context, List<Uint8List> images, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';

    // Generate PDF in isolate
    final pdfBytes = await compute(
      _generatePDF,
      PDFGenerationData(images),
    );

    // Save PDF in isolate
    await compute<Map<String, dynamic>, void>(
      (message) async {
        final bytes = message['bytes'] as Uint8List;
        final filePath = message['filePath'] as String;
        
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);
      },
      {'bytes': pdfBytes, 'filePath': filePath},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at: $filePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}

// Web PDF download function
Future<void> webDownloadPDF(
    BuildContext context, List<Uint8List> images, String filename) async {
  try {
    // Generate PDF in isolate
    final pdfBytes = await compute(
      _generatePDF,
      PDFGenerationData(images),
    );

    // Handle download in isolate
    await compute<Map<String, dynamic>, void>(
      (message) {
        final bytes = message['bytes'] as Uint8List;
        final filename = message['filename'] as String;
        
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = filename.endsWith('.pdf') ? filename : '$filename.pdf';
        
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      },
      {'bytes': pdfBytes, 'filename': filename},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF downloaded successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}