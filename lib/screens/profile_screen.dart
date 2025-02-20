import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart' as custom_widgets;

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  ProfileScreen({required this.userProfile});

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
          child: Text(
            "Name: ${userProfile['name']}, Age: ${userProfile['age']}",
          ),
        ),
      ),
    );
  }
}
