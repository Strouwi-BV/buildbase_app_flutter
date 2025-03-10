import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TimeDetail {
  final String localTime;
  final String utcTime;
  final String timezone;

  TimeDetail({required this.localTime, required this.utcTime, required this.timezone});

  factory TimeDetail.fromJson(Map<String, dynamic> json) {
    return TimeDetail(
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
}