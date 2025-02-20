import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart' as custom_widgets;

class CalendarScreen extends StatelessWidget {
  final String data;
  CalendarScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const custom_widgets.NavigationDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            context.go('/');
          }
        },
        child: Center(child: Text("Event: $data")),
      ),
    );
  }
}
