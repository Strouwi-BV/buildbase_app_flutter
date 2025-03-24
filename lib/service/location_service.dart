import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final SecureStorageService secure = SecureStorageService();


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
        return'${nearestAddress.locality}, ${nearestAddress.country}';
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

  String getTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    print('GMT$sign$hours$minutes from locSer');
    return 'GMT$sign$hours$minutes';
  }
      
}