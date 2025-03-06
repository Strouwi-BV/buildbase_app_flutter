import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';

class CalendarScreen extends StatelessWidget {
  final String data;

  const CalendarScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Calendar'),
      body: Center(child: Text(data)),
    );
  }
}
