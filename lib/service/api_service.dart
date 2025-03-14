import 'dart:convert';
import 'package:buildbase_app_flutter/model/login_response.dart';
import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<LoginResponse?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/users/login');
    final headers = {'Content-Type' : 'application/hal+json'};
    final body = jsonEncode({'email': email, 'password' : password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('In try...');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200 ) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        await _secureStorage.writeData('token', loginResponse.token);
        await _secureStorage.writeData('type', loginResponse.type);
        await _secureStorage.writeData('id', loginResponse.id);
        await _secureStorage.writeData('firstName', loginResponse.firstName);
        await _secureStorage.writeData('lastName', loginResponse.lastName);
        await _secureStorage.writeData('email', loginResponse.email);
        await _secureStorage.writeData('organizationId', loginResponse.organizationId);

        print('Login successful');
        return loginResponse;
      } else {
        print ('Login failed');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
  Future<List<ClientResponse>> getClients() async {
  String? token = await _secureStorage.readData('token');
  String? organization = await _secureStorage.readData('organizationId');
  String? userId = await _secureStorage.readData('userId');

  final url = Uri.parse('$_baseUrl/clients/active/user'); // Typfout gecorrigeerd
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'Organization': '$organization'
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Response is 200 client');
      return data.map((json) => ClientResponse.fromJson(json)).toList();
    } else {
      print('Failed to load clients: ${response.statusCode} - ${response.body}');
      throw Exception("Failed to load clients");
    }
  } catch (e) {
    print('Error fetching clients: $e');
    throw Exception("Error fetching clients: $e");
  }
}

Future<List<ProjectModel>> getProjects(String clientId) async {
  String? token = await _secureStorage.readData('token');
  String? organization = await _secureStorage.readData('organizationId');

  final url = Uri.parse('$_baseUrl/clients/$clientId/projects'); // Correcte URL
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'Organization': '$organization'
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } else {
      print('Failed to load projects: ${response.statusCode} - ${response.body}');
      throw Exception("Failed to load projects");
    }
  } catch (e) {
    print('Error fetching projects: $e');
    throw Exception("Error fetching projects: $e");
  }
}

}