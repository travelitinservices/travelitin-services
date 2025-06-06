import 'dart:convert';
import 'package:http/http.dart' as http;

class CdnService {
  final String apiBaseUrl = "http://127.0.0.1:5000/cdn/";

  Future<String?> fetchCDNFile(String folder, String fileName, String jwtToken) async {
    String filePath = "$folder/$fileName";  // Generate dynamic file path

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl$filePath'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        var fileUrl = json.decode(response.body)['url'];
        return fileUrl;
      } else if (response.statusCode == 401) {
        print("Error: Unauthorized access (Invalid JWT)");
      } else if (response.statusCode == 404) {
        print("Error: File not found");
      } else {
        print("Error: ${response.statusCode}");
      }
      return null;

    } catch (e) {
      print("Exception: $e");  // Log errors for debugging
      return null;
    }
  }
}