import 'dart:convert';
import 'package:http/http.dart' as http;

class TopicService {
  static const String url =
      'https://byte.edusaint.in/api/v1/courses/4/lessons/9';

  static Future<Map<String, dynamic>> fetchTopic() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['status'] == true) {
        return decoded['data'][0]; // taking first topic
      }
    }

    throw Exception("Failed to load topic data");
  }
}
