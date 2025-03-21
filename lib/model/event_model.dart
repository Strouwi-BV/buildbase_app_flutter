import 'package:flutter/material.dart';

class Event {
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  Color color; // Maak de kleur aanpasbaar

  Event({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.color = Colors.blue,
  });

  bool overlapsWith(Event other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }
}

class CalenderResponse {
  final String color;
  final DateTime day;

  CalenderResponse({required this.color, required this.day});

  factory CalenderResponse.fromJson(Map<String, dynamic> json) {
    return CalenderResponse(
      color: json['color'],
      day: DateTime.parse(json['day']),
    );
  }
}
