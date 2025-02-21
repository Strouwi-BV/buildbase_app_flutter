import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_service.dart';
import 'home_screen.dart' as custom_widgets;
import '../service/user_preferences.dart';


class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String userInfo = "No data found";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _localNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    loadDetails();
  }

  void fetchUserProfile() async {
    final data = await ApiSerive.fetchUserProfile(widget.userId);
    setState(() {
      userProfile = data;
      isLoading = false;

      if (userProfile != null) {
        _nameController.text = userProfile!['name'] ?? "";
        _ageController.text = userProfile!['age']?.toString() ?? "";
      }
    });
  }

   void updateUserProfile() async {
     final success = await ApiSerive.updateUserProfile(widget.userId, {
       "name": "Updated Name",
       "age": userProfile?['age'] ?? 25,
     });

    if (_formKey.currentState!.validate()) {
      final success = await ApiSerive.updateUserProfile(widget.userId, {
        "name" : _nameController.text,
        "age" : int.tryParse(_ageController.text) ?? userProfile?['age'] ?? 25,
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated!")));
        fetchUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed!")));
      }
    }
  }

  void saveLocalDetails() async {
    if (_formKey.currentState!.validate()){
      await UserPreferences.saveUserDetails(
        name: _localNameController.text, 
        surname: _surnameController.text, 
        dob: _dobController.text, 
        function: _functionController.text, 
        department: _departmentController.text,
        );

        updateDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User details saved successfully!")),
        );
    }
  }

  void updateDetails(){
    setState(() {
      userInfo = '''
        Name: ${_localNameController.text}
        Surname: ${_surnameController.text}
        Date of Birth: ${_dobController.text}
        Function: ${_functionController.text}
        Department: ${_departmentController.text}
      ''';
    });
  }

  void loadDetails() async {
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    setState(() {
      _localNameController.text = userDetails["name"] ?? "";
      _surnameController.text = userDetails["surname"] ?? "";
      _dobController.text = userDetails["dob"] ?? "";
      _functionController.text = userDetails["function"] ?? "";
      _departmentController.text = userDetails["department"] ?? "";

      updateDetails();
    });
  }

  void clearDetails() async {
    await UserPreferences.clearUserDetails();
    setState(() {
      _localNameController.clear();
      _surnameController.clear();
      _dobController.clear();
      _functionController.clear();
      _departmentController.clear();
    });

    updateDetails();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User details cleared!")),
    );
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
          child: isLoading
              ? CircularProgressIndicator()
              : userProfile == null
                  ? const Text("Failed to load profile")
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "User Details",
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              userInfo,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 20),                          // const Text("Update Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          // const SizedBox(height: 10),
                          // TextFormField(
                          //   controller: _nameController,
                          //   decoration: const InputDecoration(
                          //     labelText: "Name",
                          //     border: UnderlineInputBorder(),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return "Please enter a name";
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // const SizedBox(height: 10),
                          // TextFormField(
                          //   controller: _ageController,
                          //   decoration: const InputDecoration(
                          //     labelText: "Age",
                          //     border: UnderlineInputBorder(),
                          //   ),
                          //   keyboardType: TextInputType.number,
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return "Please enter a valid age";
                          //     }
                          //     if (int.tryParse(value) == null) {
                          //       return "Please enter your age in valid numbers";
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // const SizedBox(height: 20),
                          // Center(
                          //   child: ElevatedButton(
                          //     onPressed: updateUserProfile, 
                          //     child: const Text("Update Profile"),
                          //   ),
                          // ),
                          TextFormField(
                            controller: _localNameController,
                            decoration: InputDecoration(labelText: "Name"),
                            validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                          ),
                          TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(labelText: "Surname"),
                            validator: (value) => value!.isEmpty ? "Please enter your surname" : null,
                          ),
                          TextFormField(
                            controller: _dobController,
                            decoration: InputDecoration(labelText: "Date Of Birth"),
                            validator: (value) => value!.isEmpty ? "Please enter your date of birth" : null,
                          ),
                          TextFormField(
                            controller: _functionController,
                            decoration: InputDecoration(labelText: "Function"),
                            validator: (value) => value!.isEmpty ? "Please enter your funtion" : null,
                          ),
                          TextFormField(
                            controller: _departmentController,
                            decoration: InputDecoration(labelText: "Department"),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: saveLocalDetails,
                            child: Text("Save"),
                          ),
                          ElevatedButton(
                            onPressed: clearDetails,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text("Clear Data"),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}