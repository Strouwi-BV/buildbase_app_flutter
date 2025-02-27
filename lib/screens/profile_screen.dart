import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart' as custom_widgets;
import '../api/api_service.dart';
import '../service/user_preferences.dart';
import '../models/user_model.dart';


class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = "";
  String lastName = "";
  String birthDate = "";
  String nationality = "";
  String socialNumber = "";
  String bankAccount = "";
  String email = "";
  String workEmail = "";
  String phone = "";
  String address = "";
  String emergencyContact = "";


  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String userInfo = "No data found";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // futureUserModel = ApiSerive().fetchUsers();
    // loadDetails();
    loadUserData();
  }

  
  //  void updateUserProfile() async {
  //    final success = updateUserProfile({
  //      "name": "Updated Name",
  //      "age": userProfile?['age'] ?? 25,
  //    });
  //   if (_formKey.currentState!.validate()) {
  //     final success = await ApiSerive.updateUserProfile(widget.userId, {
  //       "name" : _nameController.text,
  //       "age" : int.tryParse(_ageController.text) ?? userProfile?['age'] ?? 25,
  //     });
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Profile updated!")));
  //       fetchUserProfile();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Update failed!")));
  //     }
  //   }
  // }
  // void saveLocalDetails() async {
  //   if (_formKey.currentState!.validate()){
  //     await UserPreferences.saveUserDetails(
  //       name: _localNameController.text, 
  //       surname: _surnameController.text, 
  //       dob: _dobController.text, 
  //       function: _functionController.text, 
  //       department: _departmentController.text,
  //       );
  //       updateDetails();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("User details saved successfully!")),
  //       );
  //   }
  // }
  // void updateDetails(){
  //   setState(() {
  //     userInfo = '''
  //       Name: ${_localNameController.text}
  //       Surname: ${_surnameController.text}
  //       Date of Birth: ${_dobController.text}
  //       Function: ${_functionController.text}
  //       Department: ${_departmentController.text}
  //     ''';
  //   });
  // }
  // void loadDetails() async {
  //   Map<String, String?> userDetails = await UserPreferences.getUserDetails();
  //   setState(() {
  //     _localNameController.text = userDetails["name"] ?? "";
  //     _surnameController.text = userDetails["surname"] ?? "";
  //     _dobController.text = userDetails["dob"] ?? "";
  //     _functionController.text = userDetails["function"] ?? "";
  //     _departmentController.text = userDetails["department"] ?? "";
  //     updateDetails();
  //   });
  // }
  // void clearDetails() async {
  //   await UserPreferences.clearUserDetails();
  //   setState(() {
  //     _localNameController.clear();
  //     _surnameController.clear();
  //     _dobController.clear();
  //     _functionController.clear();
  //     _departmentController.clear();
  //   });
  //   updateDetails();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("User details cleared!")),
  //   );
  // }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      firstName = prefs.getString('selectedFirstName') ?? "N/A";
      lastName = prefs.getString('selectedLastName') ?? "N/A";
      birthDate = prefs.getString('selectedBirthDate') ?? "N/A";
      nationality = prefs.getString('selectedNationality') ?? "N/A";
      bankAccount = prefs.getString('selectedBankAccount') ?? "N/A";
      email = prefs.getString('selectedEmail') ?? "N/A";
      workEmail = prefs.getString('selectedWorkEmail') ?? "N/A";
      phone = prefs.getString('selectedPhone') ?? "N/A";
      address = prefs.getString('selectedAddress') ?? "N/A";
      emergencyContact = prefs.getString('selectedFirstName') ?? "N/A";
    });

    print("Profile of $firstName $lastName loaded.");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/');
          }
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Name: $firstName $lastName", style: TextStyle(fontSize: 18)),
              Text("Birth Date: $birthDate"),
              Text("Nationality: $nationality"),
              Text("Social Number: $socialNumber"),
              Text("Bank Account: $bankAccount"),
              Text("Email: $email"),
              Text("Work Email: $workEmail"),
              Text("Phone: $phone"),
              Text("Address: $address"),
              Text("Emergency Contact: $emergencyContact"),
            ],
          ),
          // child: FutureBuilder<UserModel>(
          //   future: futureUserModel, 
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return CircularProgressIndicator();
          //     } else if (snapshot.hasError) {
          //       return Text("Error: ${snapshot.error}");
          //     } else if (snapshot.hasData) {
          //       UserModel userModel = snapshot.data!;
          //       return Column (
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text("Name: ${userModel.firstName} ${userModel.lastName}", style: TextStyle(fontSize: 20))
          //         ],
          //       );
          //     } else {
          //       return Text("No user found");
          //     }
          //   },
          // ),
        ),
      ),
    );
  }
}