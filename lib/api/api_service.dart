import 'dart:convert';
import 'dart:io';
import 'package:flutter_poc_reloaded/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiSerive{
  static const String baseUrl = "http://localhost:8080";

  Future<List<UserModel>> fetchUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((user) => UserModel.fromJson(user)).toList();
    } else {
      print("Failed to fetch profiles");
      throw Exception("Failed to fetch users");
    }
  }

  Future<bool> createUser(UserModel userModel) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {
        "Content-Type" : "application/json",
      },
      body: jsonEncode(userModel.toJson()),
    );

    if (response == 200){
      print("User created");
      return true;
    } else {
      print("Error: Failed to create user");
      print("Response: ${response.body}");
      return false;
    }
  }

  static Future<void> saveSelectedUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedUser', user.id);
    await prefs.setString('selectedUserName', "${user.firstName} ${user.lastName}");
    await prefs.setString('selectedFirstName', user.firstName);
    await prefs.setString('selectedLastName', user.lastName);
    await prefs.setString('selectedBirthDate', user.birthDate);
    await prefs.setString('selectedNationality', user.nationality);
    
  }

  static Future<UserModel?> getSelectedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('selectedUserId');
    String? userName = prefs.getString('selectedUserName');

    if (userId != null && userName != null) {
      List<String> nameParts = userName.split(" ");
      return UserModel(
        id: userId,
        firstName: nameParts[0],
        lastName: nameParts.length > 1 ? nameParts[1] : '';
      );
    }
    return null;
  }

  static Future<bool> clockInOrOut(int userId, int clientId, int projectId) async {
    final response = await http.post(Uri.parse("$baseUrl/clocking/$userId/$clientId/$projectId"),
    headers: {"Content-Type" : "application/json"},
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?>getClockingStatus(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/clocking/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Future<bool> updateUserProfile(int userId, Map<String, dynamic> data) async {
  //   final response = await put(
  //     Uri.parse("$baseUrl/users/$userId"),
  //     headers: {"Content-Type" : "application/json"},
  //     body: jsonEncode(data),
  //   );

  //   return response.statusCode == 200;
  // }
}