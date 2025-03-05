import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/main.dart'; // Import for buildMenuItems
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart'; // Import for HeaderBar

class ClockingDetailsScreen extends StatelessWidget {
  const ClockingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your background color here
      appBar: const HeaderBar(userName: 'Tom Peeters'), // Use HeaderBar here
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Here you can set the header of the menu, if you don't want any, you can delete it.
              // Container(
              //   height: 100, // set the height of the header
              //   color: Colors.blue, // set the background color of the header
              //   child: Center(child: Text("menu")), // set the text of the header
              // ),
              buildMenuItems(context), // Use buildMenuItems here
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text('This is the Clocking Details Screen'),
      ),
    );
  }
}