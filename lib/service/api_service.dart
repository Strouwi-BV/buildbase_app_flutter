import 'dart:convert';
import 'package:buildbase_app_flutter/model/temp_clocking_request_model.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/clocking_temp_work_response.dart';
import 'package:buildbase_app_flutter/model/login_response.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/service/no_redirects_client.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final LocationService _locationService = LocationService();
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
        await ApiService().usersAvatarComplete();
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

  Future<void> deleteAvatar() async {
    final String? userId = await _secureStorage.readData('id');
    final String? organizationId = await _secureStorage.readData(
      'organizationId',
    );
    final String? token = await _secureStorage.readData('token');

    if (userId == null || organizationId == null || token == null) {
      throw Exception("User ID, Organization ID of Token ontbreekt.");
    }

    final Uri url = Uri.parse('$_baseUrl/users/$userId/avatar');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Organization': organizationId,
      'Authorization': 'Bearer $token',
    };

    final http.Response response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Fout bij verwijderen avatar: ${response.body}");
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


  //Create full link to get Avatar
  Future<String?> usersAvatarComplete() async {
    final String? avatarLink = await usersAvatarLink();
    if (await avatarLink == '') {
      return null;
    }
    final url =
        '$avatarLink?timeStopCache=${DateTime.now() /*.millisecondsSinceEpoch*/}&${await usersAvatarSas()}&';
    await _secureStorage.writeData('avatarUrl', url);

    return url;
  }

  Future<String?> usersAvatarPost(File? image) async {
    final String? userId = await _secureStorage.readData('id');
    final String? organizationId = await _secureStorage.readData(
      'organizationId',
    );
    final String? token = await _secureStorage.readData('token');

    if (userId == null || organizationId == null || token == null) {
      throw Exception("User ID, Organization ID of Token ontbreekt.");
    }
    if (image == null) {
      throw Exception("Geen afbeelding geselecteerd.");
    }

    final url = Uri.parse('$_baseUrl/users/$userId/avatar');

    var request =
        http.MultipartRequest('POST', url)
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'Organization': organizationId,
          })
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              image.path,
              contentType: MediaType('image', 'webp'),
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      print("Avatar succesvol geüpload!");
    } else {
      throw Exception("Fout bij uploaden van avatar: ${response.statusCode}");
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.deleteAllData();
  }

  //GET /clockings/temp-work
  //Used to receive active clocking if available
  Future<ClockingTempWorkResponse?> getTempWork() async {
    String? token = await _secureStorage.readData('token');

    final url = Uri.parse('$_baseUrl/clockings/temp-work');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);
      print('In tempwork try');
      print('Statuscode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final tempWorkClockIn = ClockingTempWorkResponse.fromJson(jsonResponse);
        final String startTimeJson = json.encode(
          tempWorkClockIn.startTime.toJson(),
        );
        final String endTimeJson = json.encode(tempWorkClockIn.endTime);
        final String locationJson = json.encode(
          tempWorkClockIn.clockingLocation,
        );
        final String fullResponse = json.encode(tempWorkClockIn.toJson());

        await _secureStorage.writeData('id', tempWorkClockIn.id);
        await _secureStorage.writeData('userId', tempWorkClockIn.userId);
        await _secureStorage.writeData(
          'clockingType',
          tempWorkClockIn.clockingType,
        );
        await _secureStorage.writeData('day', tempWorkClockIn.day);
        await _secureStorage.writeData('comment', tempWorkClockIn.comment);
        await _secureStorage.writeData('startTime', startTimeJson);
        await _secureStorage.writeData('endTime', endTimeJson);
        await _secureStorage.writeData('clientId', tempWorkClockIn.clientId);
        await _secureStorage.writeData('projectId', tempWorkClockIn.projectId);
        await _secureStorage.writeData(
          'breakTime',
          tempWorkClockIn.breakTime.toString(),
        );
        await _secureStorage.writeData('clockingLocation', locationJson);

        await _secureStorage.writeData(
          'clockingTempWorkResponse',
          fullResponse,
        );

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

  //POST /clockings/temp-work
  Future<void> postTempWork(TempClockingRequestModel clockingRequest) async {
    String? token = await _secureStorage.readData('token');
    String? organization = await _secureStorage.readData('organizationId');
    String? timeZone = await _locationService.getTimeZone();

    final url = Uri.parse('$_baseUrl/clockings/temp-work');
    final headers = {
      'Content-Type' : 'application/hal+json',
      'Authorization' : 'Bearer $token',
      'Organization' : '$organization',
      'timeZone' : timeZone,
    };
    final body = jsonEncode({
      'clientId': clockingRequest.clientId,
      'projectId': clockingRequest.projectId,
      'breakTime': clockingRequest.breakTime,
      'clockingLocation': clockingRequest.clockingLocation.toJson(),
      'comment': clockingRequest.comment,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 ){
        print('Status code: ${response.statusCode}');
        print('Status 200 on post clocking');
      }

      if (response.statusCode != 200){
        print('Status code: ${response.statusCode}');
        print('there was an issue with the clock in request');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get /clients/active/user
  Future<List<ClientResponse>> getClients() async {

    String? token = await _secureStorage.readData('token');
    String? organization = await _secureStorage.readData('organizationId');
    String? userId = await _secureStorage.readData('id');
    userId = await _secureStorage.readData('id');

    final param =  {'userId': '$userId'};
    final url = Uri.parse('$_baseUrl/clients/active/user').replace(queryParameters: {
      'userId': userId,
    });
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
        throw Exception("Failed to load clients");
      }
    } catch (e) {
      print('Error fetching clients: $e');
      throw Exception(e);
    }
  }

  //GET /clients/{clientId}/projects
  Future <List<ProjectModel>> getProjects(String clientId) async {

    String? token = await _secureStorage.readData('token');
    print(clientId);
    final url = Uri.parse('$_baseUrl/clients/$clientId/projects');
    final headers = {
      'Content-Type' : 'application/json',
      'Authorization' : 'Bearer $token'
    };
    final client = NoRedirectsClient();
    final response = await client.get(url, headers: headers);

    if (response.statusCode == 302) {
      print('Response is 302 project');
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } else {
      print('Failed to load projects: ${response.statusCode}');
      throw Exception("Failed to load projects: ${response.statusCode}");
    } 

  }

}