import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

class EventDetailsScreen extends StatefulWidget {
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
    required this.location,
  }) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  latLng.LatLng? _locationCoordinates;

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
  }

  void _fetchCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(widget.location);
      if (locations.isNotEmpty) {
        setState(() {
          _locationCoordinates = latLng.LatLng(
            locations[0].latitude,
            locations[0].longitude,
          );
        });
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formattedDate,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Color(0xff13263B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Ingeklokt', widget.clockInTime, Icons.login),
            _buildInfoCard('Uitgeklokt', widget.clockOutTime, Icons.logout),
            _buildInfoCard('Notities', widget.noteText, Icons.notes),
            _buildInfoCard('Locatie', widget.location, Icons.location_on),
            SizedBox(height: 16),
            if (_locationCoordinates != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
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
                        center: _locationCoordinates,
                        zoom: 13.0,
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
                              child: Icon(
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
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff13263B),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Bewerk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  widget.onEditPressed();
                },
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
            Icon(icon, color: Color(0xff13263B), size: 28),
            SizedBox(width: 12),
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
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
