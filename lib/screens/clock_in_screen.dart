import 'package:flutter/material.dart';
import 'header_bar_screen.dart';
import 'package:buildbase_app_flutter/main.dart'; // Importeer main.dart om buildHeader en buildMenuItems te gebruiken

class ClockInScreen extends StatelessWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Clock In'),
      body: const Center(child: Text('Clock In Screen Content')),
    );
  }
}
