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

