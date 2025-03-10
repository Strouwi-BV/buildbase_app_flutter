import 'package:latlong2/latlong.dart' as latLng;
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
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
  Position? _currentLocation;
  LatLng? _currentCoordinates;
  double? latitude;
  double? longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  //Method to receive location
  Future<void> _getLocation() async {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isLocationEnabled) {
        await Geolocator.openAppSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever){
          return;
        }
      }

      _currentLocation = await Geolocator.getCurrentPosition();
      print(_currentLocation);


      setState(() {
      latitude = _currentLocation!.latitude;
      longitude = _currentLocation!.longitude;
      _currentCoordinates = LatLng(latitude!, longitude!);
      isLoading = false;
        
      });
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
            ? ClipRRect(
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
            )
            : const Center(
              child: Text('Location currently unavailable'),
            ),
        ),
    );
  }
}