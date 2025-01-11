import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class IntellisenseApi {
  static const String baseUrl = 'https://canvasai-api.shashankdaima.com';

  static Future<dynamic> solve({
    required Uint8List file,
    required Map<String, dynamic> canvasData,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/solve');
      var request = http.MultipartRequest('POST', uri);
      
      // Add file to request
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        file,
        filename: 'image.png'
      );
      request.files.add(multipartFile);
      
      // Add canvas data
      request.fields['data'] = json.encode(canvasData);
      
      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to solve: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in solve request: $e');
    }
  }
}
