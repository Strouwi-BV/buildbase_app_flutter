import 'package:flutter/material.dart';

class Event {
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  Color color; // Maak de kleur aanpasbaar
  final String? clientName;
  final String? projectName;
  final String? clockingType;
  final bool? breakTime;

  Event({
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.color = Colors.blue,
    this.clientName,
    this.projectName,
    this.clockingType,
    this.breakTime,
  });

  bool overlapsWith(Event other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      description: json['comment'],
      startTime: DateTime.parse(json['startTime']['localTime']),
      endTime: DateTime.parse(json['endTime']['localTime']),
      location: json['clockingStartLocation'],
      clientName: json['clientName'],
      projectName: json['projectName'],
      clockingType: json['clockingType'],
      breakTime: json['breakTime'],
    );
  }
}

class CalendarResponse {
  final String color;
  final DateTime day;

  CalendarResponse({required this.color, required this.day});

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    return CalendarResponse(
      color: json['color'],
      day: DateTime.parse(json['day']),
    );
  }
}

class ClockingDayView {
  final double registeredHours;
  final double expectedHours;
  final bool breakTime;
  final double breakLength;
  final List<Event> clockings;

  ClockingDayView({
    required this.registeredHours,
    required this.expectedHours,
    required this.breakTime,
    required this.breakLength,
    required this.clockings,
  });

  factory ClockingDayView.fromJson(Map<String, dynamic> json) {
    return ClockingDayView(
      registeredHours: json['registeredHours'].toDouble(),
      expectedHours: json['expectedHours'].toDouble(),
      breakTime: json['breakTime'],
      breakLength: json['breakLength'].toDouble(),
      clockings:
          (json['clockings'] as List).map((e) => Event.fromJson(e)).toList(),
    );
  }
}
