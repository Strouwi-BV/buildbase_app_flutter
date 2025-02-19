import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
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
    // final success = await ApiSerive.updateUserProfile(widget.userId, {
    //   "name": "Updated Name",
    //   "age": userProfile?['age'] ?? 25,
    // });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
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
                          const Text("Update Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              border: UnderlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: "Age",
                              border: UnderlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a valid age";
                              }
                              if (int.tryParse(value) == null) {
                                return "Please enter your age in valid numbers";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: updateUserProfile, 
                              child: const Text("Update Profile"),
                            ),
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