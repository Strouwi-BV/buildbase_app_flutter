import 'dart:convert';
import 'package:buildbase_app_flutter/model/login_response.dart';
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
    final headers = {'Content-Type': 'application/hal+json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('In try...');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        await _secureStorage.writeData('token', loginResponse.token);
        await _secureStorage.writeData('type', loginResponse.type);
        await _secureStorage.writeData('id', loginResponse.id);
        await _secureStorage.writeData('firstName', loginResponse.firstName);
        await _secureStorage.writeData('lastName', loginResponse.lastName);
        await _secureStorage.writeData('email', loginResponse.email);
        await _secureStorage.writeData(
          'organizationId',
          loginResponse.organizationId,
        );

        print('Login successful');
        return loginResponse;
      } else {
        print('Login failed');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<bool> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/password/forgot');
    final headers = {'Content-Type': 'application/hal+json'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('In try...');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Email sent successfully');
        return true;
      } else {
        print('Failed to send email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during sending email: $e');
      return false;
    }
  }
}

///endpoint is baseurl/password/forgot
///Request URL:https://sapp-strouwi-prod-northeu-buildbase.azuremicroservices.io/password/forgot
///Request Method:POST
///Status Code:200 OK
///Remote Address:20.50.64.132:443
///Referrer Policy:same-origin
