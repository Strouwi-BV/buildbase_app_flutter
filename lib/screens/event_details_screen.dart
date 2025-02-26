import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final String formattedDate;
  final String clockInTime;
  final String clockOutTime;
  final String noteText;
  final Function onEditPressed;
  final String location;

  const EventDetailsScreen({
    Key? key,
    required this.formattedDate,
    required this.clockInTime,
    required this.clockOutTime,
    required this.noteText,
    required this.onEditPressed,
    required this.location
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        backgroundColor: Color(0xff13263B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingeklokt: $clockInTime'),
            SizedBox(height: 8),
            Text('Uitgeklokt: $clockOutTime'),
            SizedBox(height: 8),
            Text('Notities: $noteText'),
            SizedBox(height: 8),
            Text('Locatie: $location'),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff13263B),
                foregroundColor: Colors.white,
              ),
              child: Text('Bewerk'),
              onPressed: () {
                onEditPressed();
              },
            ),
          ],
        ),
      ),
    );
  }
}