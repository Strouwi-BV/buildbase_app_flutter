import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final SecureStorageService secure = SecureStorageService();
  final apiService = ApiService();  
  Position? _currentLocation;


  Future<void> _loadLocationPreference() async {
      String? storedPref = await secure.readData('location_enabled');
      // setState(() {
      //   isLocationEnabled = storedPref == 'true';
      // });

      // if (isLocationEnabled) {
      //   _requestLocationPermission();
      // }
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

      // setState(() {
        
      // });
    }

    Future<void> _toggleLocation(bool geoVal) async {
      // setState(() {
      //   isLocationEnabled = geoVal;
      // });
      await secure.writeData('location_enabled', geoVal.toString());
      if (geoVal) {
        _requestLocationPermission();
      }
    }
      
}