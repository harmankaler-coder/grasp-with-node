import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const storage = FlutterSecureStorage();

  static Future<String?> refreshAccessToken() async {
    final refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'];
      await storage.write(key: "accessToken", value: newAccessToken);
      return newAccessToken;
    }

    return null;
  }

  static Future<http.Response> _authorizedRequest(
      Future<http.Response> Function(String token) requestFunction) async {

    String? token = await storage.read(key: "accessToken");

    if (token == null) {
      throw Exception("No access token found");
    }

    http.Response response = await requestFunction(token);

    if (response.statusCode == 401) {
      String? newToken = await refreshAccessToken();

      if (newToken != null) {
        response = await requestFunction(newToken);
      } else {
        await logout();
        throw Exception("Session expired. Please login again.");
      }
    }

    return response;
  }

  static Future<Course> generateCourse(String topic) async {
    final response = await _authorizedRequest((token) {
      return http.post(
        Uri.parse('$baseUrl/generate_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'topic': topic}),
      );
    });

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to generate course');
  }

  static Future<List<Course>> getCourseHistory() async {
    final response = await _authorizedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/courses'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Course(
        id: json['id'],
        topic: json['topic'],
        chapters: [],
      )).toList();
    }

    throw Exception('Failed to load history');
  }

  static Future<List<Chapter>> getCourseChapters(String courseId) async {
    final response = await _authorizedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Chapter.fromJson(json)).toList();
    }

    throw Exception('Failed to load chapters');
  }

  static Future<void> logout() async {
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
  }
}