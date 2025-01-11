import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class IntellisenseApi {
  static const String baseUrl = 'https://canvasai-api.shashankdaima.com';

  static Future<dynamic> solve({
    required File file,
    required Map<String, dynamic> canvasData,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/solve');
      var request = http.MultipartRequest('POST', uri);
      
      // Add file to request
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: file.path.split('/').last
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
