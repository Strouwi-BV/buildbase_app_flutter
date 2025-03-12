import 'package:buildbase_app_flutter/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class LiveClockingLocationScreen extends StatefulWidget {

  const LiveClockingLocationScreen({Key? key}) : super(key: key);

  @override
  State<LiveClockingLocationScreen> createState() => _LiveClockingLocationScreenState();

}

class _LiveClockingLocationScreenState extends State<LiveClockingLocationScreen> {

  final SecureStorageService secure = SecureStorageService();
  final LocationService location = LocationService();

  Position? _currentLocation;
  LatLng? _currentCoordinates;
  double? latitude;
  double? longitude;
  String? nearestAddress;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    location.requestPermission();
    location.isLocationServiceEnabled();
    getCurrentLocation();
  }

  //Method to receive location
  Future<void> getCurrentLocation() async {
    final position = await location.getCurrentLocation();
    if (position != null) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        _currentCoordinates = LatLng(latitude!, longitude!);
        isLoading = false;
        print('Location: ${position.latitude}, ${position.longitude}');
      });
      await getNearestAddress(position.latitude, position.longitude);
    }
  }

  //Method to receive nearest address
  Future<void> getNearestAddress(double latitude, double longitude) async {
    final address = await location.getNearestAddress(latitude, longitude);

    if (address != null) {
      setState(() {
        nearestAddress = address;
        print(address);
      });
    } else {
      setState(() {
        nearestAddress = 'Address not found';
      });
    }
  }

    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Live Clocking Location'),
      body: isLoading 
        ? const Center(
          child: CircularProgressIndicator()
        )
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: _currentCoordinates != null
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        initialCenter: _currentCoordinates!,
                        minZoom: 13.0,
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
                              point: _currentCoordinates!,
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
              SizedBox(height: 20),
              Text(
                nearestAddress ?? 'Address loading...'
              ),
              ],
            )
            : const Center(
              child: Text('Location currently unavailable'),
            ),
        ),
    );
  }
}