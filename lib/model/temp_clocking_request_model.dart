
import 'package:buildbase_app_flutter/model/clocking_location.dart';

class TempClockingRequestModel {
  final String clientId;
  final String projectId;
  final bool breakTime;
  final ClockingLocation clockingLocation;
  final String comment;

  TempClockingRequestModel({
    required this.clientId,
    required this.projectId,
    required this.breakTime,
    required this.clockingLocation,
    required this.comment,
  });

  Map<String, dynamic> toJson(){
    return {
      'clientId' : clientId,
      'projectId' : projectId,
      'breakTime' : breakTime,
      'clockingLocation' : clockingLocation,
      'comment' : comment,
    };
  }
}