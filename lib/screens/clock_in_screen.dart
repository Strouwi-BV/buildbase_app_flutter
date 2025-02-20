import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart' as custom_widgets;

class ClockInScreen extends StatelessWidget {
  // final int employeeId;
  // ClockInScreen({required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: const Text(
          "Clock In",
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
        // child: Center(child: Text("Employee ID: $employeeId")),
      ),
    );
  }
}
