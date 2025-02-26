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
              locations[0].latitude, locations[0].longitude);
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
        title: Text(widget.formattedDate),
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
            Text('Ingeklokt: ${widget.clockInTime}'),
            SizedBox(height: 8),
            Text('Uitgeklokt: ${widget.clockOutTime}'),
            SizedBox(height: 8),
            Text('Notities: ${widget.noteText}'),
            SizedBox(height: 8),
            Text('Locatie: ${widget.location}'),
            SizedBox(height: 16),
            if (_locationCoordinates != null)
              Expanded(
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
                          width: 80.0,
                          height: 80.0,
                          point: _locationCoordinates!,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff13263B),
                foregroundColor: Colors.white,
              ),
              child: Text('Bewerk'),
              onPressed: () {
                widget.onEditPressed();
              },
            ),
          ],
        ),
      ),
    );
  }
}