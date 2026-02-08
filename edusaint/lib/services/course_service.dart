import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';

class CourseService {
  static const String url = "https://byte.edusaint.in/api/v1/courses";
  static const String cacheKey = "cached_courses";

  static Future<List<Course>> fetchCourses({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!force && prefs.containsKey(cacheKey)) {
      final cached = json.decode(prefs.getString(cacheKey)!);
      return (cached as List).map((e) => Course.fromJson(e)).toList();
    }

    final response = await http.get(Uri.parse(url));
    final raw = json.decode(response.body)['data'] as List;

    final cleanList = raw.where((e) {
      return e['course_name'] != null &&
          e['course_name'].toString().trim().isNotEmpty;
    }).toList();

    prefs.setString(cacheKey, json.encode(cleanList));

    return cleanList.map((e) => Course.fromJson(e)).toList();
  }
}
