import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart' as custom_widgets;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}



class _LocationScreenState extends State<LocationScreen> {
  loc.Location location = loc.Location();
  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  Position? _geolocatorPosition;


//Location Package
  void _requestLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {});
  }

//Geolocator
  Future<void> _getGeolocatorLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever){
        return;
      }
    }

    _geolocatorPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: const Text(
          "Location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: const Text("Get Location (location package)"),
            ),
            ElevatedButton(
              onPressed: _getGeolocatorLocation,
              child: const Text("Get Location (Geolocator)"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Location Package Data:",
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            Text("Latitude: ${_locationData?.latitude?.toStringAsFixed(6) ?? "Unknown"}"),
            Text("Longitude: ${_locationData?.longitude?.toStringAsFixed(6) ?? "Unknown"}"),
            const SizedBox(height: 20),
            const Text(
              "Geolocator Data:",
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            Text("Geolocator Latitude: ${_geolocatorPosition?.latitude.toStringAsFixed(6) ?? "Unknown"}"),
            Text("Geolocator Longitude: ${_geolocatorPosition?.longitude.toStringAsFixed(6) ?? "Unknown"}"),
          ],
        ),
      ),
    );
  }
}
