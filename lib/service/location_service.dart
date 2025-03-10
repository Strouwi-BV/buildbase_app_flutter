import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final SecureStorageService secure = SecureStorageService();
  final apiService = ApiService();

  //Request permission to access location
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  //Check if location is enabled
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  //Toggle location access (android only, no support on iOS)
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
  
  //Receive the current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return null;
      }

      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();
      print('${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print ('Error getting location: $e');
      return null;
    }
  }

  //Receive permanent updates when moving more than 10 meters
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  //Receive nearest address based on received location
  Future<String?> getNearestAddress(double latitude, double longitude) async {
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark nearestAddress = placemarks.first;
        return'${nearestAddress.street},${nearestAddress.locality}, ${nearestAddress.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  //Calculate distance between 2 points for when start and end differ
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude
  ) { return Geolocator.distanceBetween(
    startLatitude, 
    startLongitude, 
    endLatitude, 
    endLongitude
    );
  }
      
}