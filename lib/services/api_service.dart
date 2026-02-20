import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const storage = FlutterSecureStorage();
  static Future<Course> generateCourse(String topic) async {
    String? token = await storage.read(key: "accessToken");
    final response = await http.post(
      Uri.parse('$baseUrl/generate_course'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'topic': topic}),
    );

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to generate course');
  }

  static Future<List<Course>> getCourseHistory() async {
    try {
      String? token = await storage.read(key: "accessToken");
      final response = await http.get(Uri.parse('$baseUrl/courses'),
        headers: {
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Course(
          id: json['id'],
          topic: json['topic'],
          chapters: [],
        )).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  static Future<List<Chapter>> getCourseChapters(String courseId) async {
    String? token = await storage.read(key: "accessToken");
    final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Chapter.fromJson(json)).toList();
    }
    throw Exception('Failed to load chapters');
  }
}