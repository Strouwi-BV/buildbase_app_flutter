import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart' as custom_widgets;
import '../api/api_service.dart';
import '../service/user_preferences.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';


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

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      firstName = prefs.getString('selectedFirstName') ?? "N/A";
      lastName = prefs.getString('selectedLastName') ?? "N/A";
      birthDate = prefs.getString('selectedBirthDate') ?? "N/A";
      nationality = prefs.getString('selectedNationality') ?? "N/A";
      socialNumber = prefs.getString('selectedSocialNumber') ?? "N/A";
      bankAccount = prefs.getString('selectedBankAccount') ?? "N/A";
      email = prefs.getString('selectedEmail') ?? "N/A";
      workEmail = prefs.getString('selectedWorkEmail') ?? "N/A";
      phone = prefs.getString('selectedPhone') ?? "N/A";
      address = prefs.getString('selectedAddress') ?? "N/A";
      emergencyContact = prefs.getString('selectedFirstName') ?? "N/A";
    });

    print("Profile of $firstName $lastName loaded.");
  }

  void navigateToEditScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
    loadUserData();
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
              SizedBox(height: 30),
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
              SizedBox(height: 20),
              // Center(
              //   child: Button,
              // )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToEditScreen,
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16)
          ),
        ],
      ),
    );
  }
}