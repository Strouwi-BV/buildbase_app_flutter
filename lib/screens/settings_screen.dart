import 'package:buildbase_app_flutter/service/api_service.dart';
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
    bool isLocationEnabled = false;
    final SecureStorageService secure = SecureStorageService();
    final apiService = ApiService();
    Position? _currentLocation;
    double? _latitude;
    double? _longitude;

    @override
    void initState() {
      super.initState();
      _loadLocationPreference();
    }

    Future<void> _getAvatar(String userId) async {
      String? userId = await secure.readData('id');
      apiService.fetchUserAvatar(userId);
      print("Get avatar called");
      
    }

    Future<void> _loadLocationPreference() async {
      String? storedPref = await secure.readData('location_enabled');
      setState(() {
        isLocationEnabled = storedPref == 'true';
      });

      if (isLocationEnabled) {
        _requestLocationPermission();
      }
    }

    Future<void> _requestLocationPermission() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }

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
        
      });
    }

    Future<void> _toggleLocation(bool geoVal) async {
      setState(() {
        isLocationEnabled = geoVal;
      });
      await secure.writeData('location_enabled', geoVal.toString());
      if (geoVal) {
        _requestLocationPermission();
      }
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
                    value: isLocationEnabled,
                    onChanged: _toggleLocation,
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
                    onPressed: _getLocation, 
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
                  // ElevatedButton(
                  //   onPressed: _getAvatar, 
                  //   child: const Text("Get avatar"),
                  // ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  
