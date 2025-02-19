import 'dart:convert';
import 'package:http/http.dart';

class ApiSerive{
  static const String baseUrl = "https://jsonplaceholder.typicode.com";

  static Future<Map<String, dynamic>?> fetchUserProfile(int userId) async {
    final response = await get(Uri.parse("$baseUrl/users/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: Failed to load profile");
      return null;
    }
  }

  static Future<bool> updateUserProfile(int userId, Map<String, dynamic> data) async {
    final response = await put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }
}