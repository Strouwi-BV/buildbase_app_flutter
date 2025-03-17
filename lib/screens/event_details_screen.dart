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
            _buildInfoCard('Ingeklokt', widget.clockInTime, Icons.login),
            _buildInfoCard('Uitgeklokt', widget.clockOutTime, Icons.logout),
            _buildInfoCard('Notities', widget.noteText, Icons.notes),
            _buildInfoCard('Locatie', widget.location, Icons.location_on),
            const SizedBox(height: 16),
            if (_locationCoordinates != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 300,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            _locationCoordinates ??
                            latLng.LatLng(
                              52.3676,
                              4.9041,
                            ), // Default to Amsterdam
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: _locationCoordinates!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff13263B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  // Correcte manier om naar EditClockInScreen te navigeren
                  context.push(
                    '/edit-clock-in',
                    extra: {
                      'date': widget.date,
                      'currentClockIn': widget.clockInTime,
                      'currentClockOut': widget.clockOutTime,
                      'currentNotes': widget.noteText,
                    },
                  );
                },
              child: const Text('Verwijder')),
              )
                child: const Text(
                  'Bewerk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff13263B), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
