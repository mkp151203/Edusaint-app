import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = "https://byte.edusaint.in/api/v1/me/student";

  /// ------------------------------------------------
  /// GET PROFILE
  /// ------------------------------------------------
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("PROFILE GET STATUS: ${response.statusCode}");
      print("PROFILE GET RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["status"] == true &&
            decoded["data"] is Map<String, dynamic>) {
          return decoded["data"];
        }
      }

      return {};
    } catch (e) {
      print("PROFILE GET ERROR: $e");
      return {};
    }
  }

  /// ------------------------------------------------
  /// UPDATE PROFILE
  /// ------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String studentClass,
    required String mobile,
    File? imageFile,
  }) async {
    final url = Uri.parse("https://byte.edusaint.in/api/v1/me/student");

    try {
      final request = http.MultipartRequest("POST", url);

      // 🔹 SQL column mapping (students table)
      request.fields["name"] = name;
      request.fields["class"] = studentClass;
      request.fields["mobile"] = mobile;

      // 🔹 Image is optional
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "image", // must match backend key
            imageFile.path,
          ),
        );
      }

      // 🔹 Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print("PROFILE UPDATE STATUS: ${streamedResponse.statusCode}");
      print("PROFILE UPDATE RESPONSE: $responseBody");

      final decoded = jsonDecode(responseBody);

      return decoded;
    } catch (e) {
      print("PROFILE UPDATE ERROR: $e");
      return {"status": false, "message": "Profile update failed"};
    }
  }
}
