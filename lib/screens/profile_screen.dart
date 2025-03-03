import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'nav_widget_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom Peeters'),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[buildHeader(context), buildMenuItems(context)],
          ),
        ),
      ),
      body: Center(
        child: Text('Profile Screen Content for user $userId'),
      ),
    );
  }
}
