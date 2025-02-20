import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String keyName = "name";
  static const String keySurname = "surname";
  static const String keyDob = "dob";
  static const String keyFunction = "function";
  static const String keyDepartment = "Department";

  static Future<void> saveUserDetails({
    required String name,
    required String surname,
    required String dob,
    required String function,
    required String department,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(keyName, name);
    await prefs.setString(keySurname, surname);
    await prefs.setString(keyDob, dob);
    await prefs.setString(keyFunction, function);
    await prefs.setString(keyDepartment, department);
  }

  static Future<Map<String, String?>> getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString(keyName),
      "surname": prefs.getString(keySurname),
      "dob": prefs.getString(keyDob),
      "function": prefs.getString(keyFunction),
      "department": prefs.getString(keyDepartment),
    };
  }

  static Future<void> clearUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}