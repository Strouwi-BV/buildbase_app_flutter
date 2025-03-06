import 'package:flutter/material.dart';
import 'header_bar_screen.dart';

class ClockInScreen extends StatelessWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom peeters'),
      body: const Center(child: Text('Clock In Screen Content')),
    );
  }
}
