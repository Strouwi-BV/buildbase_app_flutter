import 'dart:convert';
import 'dart:typed_data';
import 'package:buildbase_app_flutter/model/clocking_temp_work_response.dart';
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

  static final _startTimeKey = 'startTime';
  static final _endTimeKey = 'endTime';
  static final _fullResponseKey = '';

  //POST /users/login
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

  Future<String?> getUserEmail() async {
    return await _secureStorage.readData('email');
  }

  Future<String?> getUserFirstName() async {
    return await _secureStorage.readData('firstName');
  }

  Future<String?> getUserLastName() async {
    return await _secureStorage.readData('lastName');
  }

  Future<String?> usersAvatarLink() async {
    final String? userId = await _secureStorage.readData('id');
    final String? organizationId = await _secureStorage.readData(
      'organizationId',
    );
    final String? token = await _secureStorage.readData('token');

    if (userId == null || organizationId == null || token == null) {
      return null;
    }

    final url = Uri.parse('$_baseUrl/users/$userId/avatar');
    final headers = {
      'Content-Type': 'application/json',
      'Organization': organizationId,
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> usersAvatarSas() async {
    final String? organizationId = await _secureStorage.readData(
      'organizationId',
    );
    final String? token = await _secureStorage.readData('token');
    final url = Uri.parse('$_baseUrl/fileExport/blob/sas');

    if (organizationId == null || token == null) {
      return null;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Organization': organizationId,
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> usersAvatarComplete() async {
    final String? avatarLink = await usersAvatarLink();
    print('avatarLink: $avatarLink');
    if (await avatarLink == '') {
      return null;
    }
    final url =
        '$avatarLink?timeStopCache=${DateTime.now() /*.millisecondsSinceEpoch*/}&${await usersAvatarSas()}&';
    print('urll: $url');

    return url;
  }

  Future<void> logout() async {
    await _secureStorage.deleteAllData();
  }

///baseurl/users/{userId}/avatar
///Request Method:GET
///GET /fileExport/blob/sas
///https://sablobstoragedevnortheu.blob.core.windows.net/67c858c483fe595f6082632e/users/67c858c5f034282c4b051bf4/avatar.jpg
///?
///timeStopCache=1741359729444
///&
///sv=2023-11-03&st=2025-03-07T14%3A57%3A12Z&se=2025-03-07T16%3A02%3A12Z&sr=c&sp=r&sig=p52fdNN54gGZqdSRrvbsAP4p5CZXuL3F9vdeyMX%2B1VA%3D
///&

  //GET /clockings/temp-work
  Future<ClockingTempWorkResponse?> getTempWork() async {

    String? token = await _secureStorage.readData('token');


    final url = Uri.parse('$_baseUrl/clockings/temp-work');
    final headers = {
      'Authorization' : 'Bearer $token',
    };


    try {

      final response = await http.get(url, headers: headers);
      print('In tempwork try');
      print('Statuscode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final tempWorkClockIn = ClockingTempWorkResponse.fromJson(jsonResponse);
        final String startTimeJson = json.encode(tempWorkClockIn.startTime.toJson());
        final String endTimeJson = json.encode(tempWorkClockIn.endTime);
        final String locationJson = json.encode(tempWorkClockIn.clockingLocation);
        final String fullResponse = json.encode(tempWorkClockIn.toJson());

        await _secureStorage.writeData('id', tempWorkClockIn.id);
        await _secureStorage.writeData('userId', tempWorkClockIn.userId);
        await _secureStorage.writeData('clockingType', tempWorkClockIn.clockingType);
        await _secureStorage.writeData('day', tempWorkClockIn.day);
        await _secureStorage.writeData('comment', tempWorkClockIn.comment);
        await _secureStorage.writeData('startTime', startTimeJson);
        await _secureStorage.writeData('endTime', endTimeJson);
        await _secureStorage.writeData('clientId', tempWorkClockIn.clientId);
        await _secureStorage.writeData('projectId', tempWorkClockIn.projectId);
        await _secureStorage.writeData('breakTime', tempWorkClockIn.breakTime.toString());
        await _secureStorage.writeData('clockingLocation', locationJson);

        await _secureStorage.writeData('clockingTempWorkResponse', fullResponse);

        return tempWorkClockIn;
      } else {
        print('Failed to fetch temp work data');
        return null;
      }
    } catch (e) {
        print('Error fetching data $e');
        return null;
    }
  }
}
