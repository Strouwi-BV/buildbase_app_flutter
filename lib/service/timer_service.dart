import 'package:flutter/material.dart';
import 'dart:async';

class TimerProvider with ChangeNotifier {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00:00";
  String _startTime = ""; // Voeg een veld toe om de starttijd op te slaan

  String get elapsedTime => _elapsedTime;
  String get startTime => _startTime; // Getter voor startTime

  void setStartTime(String startTime) {
    _startTime = startTime; // Methode om de starttijd in te stellen
    notifyListeners();
  }

  void startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedTime = _formatElapsedTime(_stopwatch.elapsed);
      notifyListeners();
    });
  }

  void stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _stopwatch.reset();
    _elapsedTime = "00:00:00";
    notifyListeners();
  }

  String _formatElapsedTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}