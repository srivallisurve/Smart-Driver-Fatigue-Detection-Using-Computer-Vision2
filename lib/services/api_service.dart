import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      'https://smart-driver-fatigue-detection-using.onrender.com';

  static Future<Map<String, dynamic>> detectDrowsiness(
      Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/detect'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );

      var response = await request.send();
      var responseBody =
          await response.stream.bytesToString();
      var result = jsonDecode(responseBody);

      return result;
    } catch (e) {
      return {
        'ear': 0.0,
        'mar': 0.0,
        'frame_counter': 0,
        'drowsy_score': 0,
        'status': 'ERROR'
      };
    }
  }

  static Future<bool> checkHealth() async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/health'),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
