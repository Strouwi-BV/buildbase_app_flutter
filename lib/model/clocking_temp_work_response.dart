import 'package:buildbase_app_flutter/model/clocking_location.dart';
import 'package:buildbase_app_flutter/model/detailed_timestamp.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class ClockingTempWorkResponse {
  final String id;
  final String userId;
  final String clockingType;
  final String? day;
  final String comment;
  final DetailedTimeStamp startTime;
  final DetailedTimeStamp? endTime;
  final String clientId;
  final String projectId;
  final bool breakTime;
  final ClockingLocation clockingLocation;

  ClockingTempWorkResponse({
    required this.id,
    required this.userId,
    required this.clockingType,
    this.day,
    required this.comment,
    required this.startTime,
    this.endTime,
    required this.clientId,
    required this.projectId,
    required this.breakTime,
    required this.clockingLocation,
  });

  factory ClockingTempWorkResponse.fromJson(Map<String, dynamic> json) {
    return ClockingTempWorkResponse(
      id: json['id'], 
      userId: json['userId'], 
      clockingType: json['clockingType'], 
      day: json['day'], 
      comment: json['comment'], 
      startTime: DetailedTimeStamp.fromJson(json['startTime']), 
      endTime: json['endTime'] != null
          ? DetailedTimeStamp.fromJson(json['endTime'])
          : null,
      clientId: json['clientId'], 
      projectId: json['projectId'], 
      breakTime: json['breakTime'], 
      clockingLocation: ClockingLocation.fromJson(json['clockingLocation'])
    );
  }

  Map<String, dynamic> json() {
    return {
      'id': id,
      'userId': userId,
      'clockingType': clockingType,
      'day': day,
      'comment': comment,
      'startTime': startTime.toJson(),
      'endTime': endTime?.toJson(),
      'clientId': clientId,
      'projectId': projectId,
      'beakTime': breakTime,
      'clockingLocation': clockingLocation.toJson(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clockingType': clockingType,
      'day': day,
      'comment': comment,
      'startTime': startTime.toJson(),
      'endTime': endTime?.toJson(),
      'clientId': clientId,
      'projectId': projectId,
      'beakTime': breakTime,
      'clockingLocation': clockingLocation.toJson(),
    };
  }
}