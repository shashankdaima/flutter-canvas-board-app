import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class ImageUploadHandler {
  static Future<Uint8List?> pickImage(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Web-specific implementation
        final input = html.FileUploadInputElement()..accept = 'image/*';
        input.click();

        await input.onChange.first;
        if (input.files?.isNotEmpty ?? false) {
          final file = input.files!.first;
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          
          final completer = Completer<Uint8List>();
          reader.onLoadEnd.listen((event) {
            completer.complete(Uint8List.fromList(reader.result as List<int>));
          });
          
          return await completer.future;
        }
      } else {
        // Mobile implementation remains the same
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          return await image.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      return null;
    }
  }
}