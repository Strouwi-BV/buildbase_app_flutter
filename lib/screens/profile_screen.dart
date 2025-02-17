import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  ProfileScreen({required this.userProfile});

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
          child: Text("Name: ${userProfile['name']}, Age: ${userProfile['age']}"),
        ),
      ),
    );
  }
}