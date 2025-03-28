import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TimerProvider with ChangeNotifier {

  final SecureStorageService _secure = SecureStorageService();
  final ApiService _apiService = ApiService();

  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00:00";
  String _startTime = ""; // Voeg een veld toe om de starttijd op te slaan
  bool isClockedIn = false;

  String get elapsedTime => _elapsedTime;
  String get startTime => _startTime; // Getter voor startTime
  bool get isClocking => isClockedIn;

  void setStartTime(String startTime) {
    _startTime = startTime; // Methode om de starttijd in te stellen
    notifyListeners();
  }

  void startTimer() {
    // _isClocking = true;
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedTime = _formatElapsedTime(_stopwatch.elapsed);
      notifyListeners();
    });
  }

  void stopTimer() {
    isClockedIn = false;
    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    // isClockedIn = false;
    _stopwatch.reset();
    _elapsedTime = "00:00:00";
    notifyListeners();
    // _restoreTimer();
  }

  String _formatElapsedTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> checkActiveClocking() async {
    print('Starting clocking check');
    try {

      final response = await _apiService.getTempWork();

      if (response != null && response.clientId.isNotEmpty) {
        _startTime = response.startTime.utcTime.toString();
        isClockedIn = true;

        await _secure.writeData('activeClocking', 'true');
        await _secure.writeData('activeStartTime', _startTime);

        _restoreTimer();

      } else {

        resetTimer();

        await _secure.writeData('activeClocking', 'false');
        await _secure.deleteData('activeStartTime');

      }

      notifyListeners();

    } catch (e) {
      debugPrint('Error in check active clocking: $e');
    }
  }

  Future<void> _restoreTimer() async {
    try {

      final response = await _apiService.getTempWork();

      if (response != null && response.clientId.isNotEmpty) {
        isClockedIn = true;
        DateTime startDateTime = DateTime.parse(response.startTime.utcTime);
        Duration elapsedDuration = DateTime.now().difference(startDateTime);


        _stopwatch = Stopwatch();
        _stopwatch.start();

        _elapsedTime = _formatElapsedTime(elapsedDuration);

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          Duration newElapsed = elapsedDuration + _stopwatch.elapsed;
          _elapsedTime = _formatElapsedTime(newElapsed);
          notifyListeners();
        });

        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  TimerProvider() {
    checkActiveClocking();
  }
}