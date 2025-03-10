import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SettingsScreen extends StatefulWidget {


  const SettingsScreen({Key? key,}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

  class _SettingsScreenState extends State<SettingsScreen> {

    final SecureStorageService secure = SecureStorageService();
    final LocationService location = LocationService();
    final apiService = ApiService();
    Position? _currentLocation;
    LatLng? _currentCoordinates;
    double? latitude;
    double? longitude;
    bool locationEnabled = false;

    @override
    void initState() {
      super.initState();
      checkLocationServiceStatus();
      // location.requestPermission();
      // location.isLocationServiceEnabled();
    }

    Future<void> checkLocationServiceStatus() async {
      bool isLocationEnabled = await location.isLocationServiceEnabled();
      setState(() {
        locationEnabled = isLocationEnabled;
      });
    }

    Future<void> toggleLocationService() async {
      await location.openLocationSettings();
      await checkLocationServiceStatus();
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: const HeaderBar(title: 'Settings'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Location Services',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: locationEnabled,
                    onChanged: (value) async {
                      await toggleLocationService();
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: location.getCurrentLocation, 
                    child: const Text("Get location"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    _currentLocation.toString() ?? "No location yet"
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: apiService.getTempWork, 
                    child: const Text("Get avatar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  
