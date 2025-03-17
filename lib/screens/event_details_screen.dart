import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/calendar_screen.dart'; // Importeer de CalendarScreen klasse
import 'package:buildbase_app_flutter/screens/edit_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
                Navigator.pop(context,'edit');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${event.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description: ${event.description ?? 'No description'}'),
            const SizedBox(height: 8),
            Text('Start Time: ${event.startTime}'),
            const SizedBox(height: 8),
            Text('End Time: ${event.endTime}'),
            const SizedBox(height: 8),
            Text('Location: ${event.location ?? 'No location'}'),
             const SizedBox(height: 16),
              Center(
                 child: ElevatedButton(
                  onPressed: () {
                  Navigator.pop(context,event);
                },
              child: const Text('Verwijder')),
              )
          ],
        ),
      ),
    );
  }
}