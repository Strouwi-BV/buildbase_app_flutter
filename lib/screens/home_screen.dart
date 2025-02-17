import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/calendar', extra: "Meeting at 11:30 AM");
              },
              child: Text("Go to Calendar"),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/location/37.7749/-122.4194'); //example coords
              },
              child: Text("Go to Location"),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/profile', extra : {"name" : "John Doe" , "age" : 30});
              },
              child: Text("Go to Profile"),
            ),
          ],
        ),
      ),
    );
  }
}