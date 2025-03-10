
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ClockingLocation {
  final double longitude;
  final double latitude;
  final String city;
  final String countryCode;

  ClockingLocation({required this.longitude, required this.latitude, required this.city, required this.countryCode});

  factory ClockingLocation.fromJson(Map<String, dynamic> json) {

    return ClockingLocation(
      longitude: json['longitude'].toDouble(), 
      latitude: json['latitude'].toDouble(), 
      city: json['city'], 
      countryCode: json['countryCode'],
    );
  }

  Map<String, dynamic> json() {
    return {
      'longitude': longitude,
      'latitude': latitude,
      'city': city,
      'countryCode': countryCode,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'longitude': longitude,
      'latitude': latitude,
      'city': city,
      'countryCode': countryCode,
    };
  }
}