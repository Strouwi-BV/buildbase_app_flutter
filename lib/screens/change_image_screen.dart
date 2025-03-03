import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';

class ChangeImageScreen extends StatelessWidget {
  const ChangeImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wijzig Afbeelding',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff13263B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Hier kun je je afbeelding wijzigen.'),
      ),
    );
  }
}
