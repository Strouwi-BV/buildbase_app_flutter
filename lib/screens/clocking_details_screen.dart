import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/main.dart'; // Import for buildMenuItems
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart'; // Import for HeaderBar

class ClockingDetailsScreen extends StatelessWidget {
  const ClockingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your background color here
      appBar: const HeaderBar(), // Use HeaderBar here
      body: const Center(child: Text('This is the Clocking Details Screen')),
    );
  }
}
