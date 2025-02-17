import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatelessWidget {
  final String data;
  CalendarScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0){
            context.go('/');
          }
        },
        child: Center(child: Text("Event: $data"))
      ),
    );
  }
}