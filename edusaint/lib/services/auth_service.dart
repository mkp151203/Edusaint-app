import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://byte.edusaint.in/api/v1/auth";

  // -------------------- LOGIN --------------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final decoded = _safeDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": decoded};
      } else {
        return {
          "success": false,
          "message": decoded["message"] ?? "Login failed. Try again.",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network Error: $e"};
    }
  }

  // -------------------- SIGNUP --------------------
  static Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final body = {"email": email, "password": password};

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final decoded = _safeDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        return {"success": true, "data": decoded};
      } else {
        return {
          "success": false,
          "message": decoded["message"] ?? "Signup failed. Try again.",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network Error: $e"};
    }
  }

  // -------------------- SAFE JSON DECODER --------------------
  static dynamic _safeDecode(String response) {
    try {
      return jsonDecode(response);
    } catch (_) {
      return {"message": response};
    }
  }
}
