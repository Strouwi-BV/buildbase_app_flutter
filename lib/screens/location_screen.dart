import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocationScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  LocationScreen({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
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
          child: Text("Coordinates: ($latitude, $longitude)"),
        ),
      ),
    );
  }
}