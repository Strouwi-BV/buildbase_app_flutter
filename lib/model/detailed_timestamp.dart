import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DetailedTimeStamp {
  final String localTime;
  final String utcTime;
  final String timezone;

  DetailedTimeStamp({required this.localTime, required this.utcTime, required this.timezone});

  factory DetailedTimeStamp.fromJson(Map<String, dynamic> json) {
    return DetailedTimeStamp(
      localTime: json['localTime'],
      utcTime: json['utcTime'],
      timezone: json['timeZone'],
    );
  }

  Map<String, dynamic> json() {
    return {
      'localTime': localTime,
      'utcTime': utcTime,
      'timezone': timezone,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'localTime': localTime,
      'utcTime': utcTime,
      'timezone': timezone,
    };
  }

  String getLocalTimeIso() {
    final parsedDate = DateTime.parse(localTime);
    return parsedDate.toIso8601String();
  }

  String getUtcTimeIso() {
    final parsedDate = DateTime.parse(utcTime);
    return parsedDate.toIso8601String();
  }
}