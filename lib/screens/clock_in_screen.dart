import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClockInScreen extends StatelessWidget {
  final int employeeId;
  ClockInScreen({required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clock In"),
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
        child: Center(child: Text("Employee ID: $employeeId")),
      ),
    );
  }
}