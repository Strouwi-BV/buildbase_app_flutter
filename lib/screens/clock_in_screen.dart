import 'package:flutter/material.dart';
import 'package:flutter_poc_reloaded/api/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart' as custom_widgets;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  static _ClockInScreenState? instance;

  @override
  State<ClockInScreen> createState() {
    final state = _ClockInScreenState();
    instance = state;
    return state;
  }
}

class _ClockInScreenState extends State<ClockInScreen> {
  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);
  bool isClockedIn = false;
  List<String> timeStamps = [];
  final _formKey = GlobalKey<FormState>();
  bool _registrationCompleted = false;
  String? _selectedKlantnaam;
  String? _selectedProjectnaam;
  final List<String> _klantnamen = ['Strouwi', 'Klant B', 'Klant C'];
  final List<String> _projectnamen = ['Buildbase app', 'Project X', 'Project Y'];
  bool _needsRegistration = false;
  bool _showTimer = true;
  String _currentLocation = '';

  //Added DevAPI
  int? selectedClientId;
  int? selectedProjectId;
  bool _isClockedIn = false;


  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _loadTimeStamps();
    _loadTimerState();
  }

  void _loadTimeStamps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      timeStamps = prefs.getStringList('timeStamps') ?? [];
    });
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKlantnaam = prefs.getString('selectedKlantnaam');
      _selectedProjectnaam = prefs.getString('selectedProjectnaam');
      isClockedIn = prefs.getBool('isClockedIn') ?? false;

      // Als we niet ingeklokt zijn en van scherm wisselen, dan registratie tonen
      _showTimer = isClockedIn;

      if (isClockedIn) {
        int? startTime = prefs.getInt('clockInTimestamp');
        if (startTime != null) {
          int elapsedTime = DateTime.now().millisecondsSinceEpoch - startTime;
          _stopWatchTimer.setPresetTime(mSec: elapsedTime);
          _stopWatchTimer.onStartTimer();
          _scheduleNotificationUpdates();
        }
      }
    });
  }

  void _saveTimeStamps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('timeStamps', timeStamps);
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Future<void> _clockIn() async {
    // Als er geen project/klant is geselecteerd, dan kan er niet ingeklokt worden
    if (_selectedKlantnaam == null || _selectedProjectnaam == null) {
      return;
    }
    try {
      String location = await _getCurrentLocation(); // Haal de locatie op
      final startTime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        isClockedIn = true;
        _showTimer = true; // Na inklokken altijd timer tonen
        _stopWatchTimer.onStartTimer();
        _saveTimerState(startTime);
        String timeStamp =
            'Ingeklokt: ${_formatDateTime(DateTime.now())}';
        timeStamps.add(timeStamp);
        _saveTimeStamps();
        _currentLocation = location;
      });
        final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentLocation', _currentLocation);
      _scheduleNotificationUpdates();
    } catch (e) {
      print('Error getting location: $e');
      // Toon een error of fallback naar een default locatie
    }
  }

  Future<String> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Locatie diensten zijn uitgeschakeld.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Locatie toestemming is geweigerd.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Locatie toestemming is permanent geweigerd.';
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.locality}"; // geef de stad terug
      }
      return "Locatie niet gevonden";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> _saveTimerState([int? startTime]) async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedKlantnaam != null) {
      await prefs.setString('selectedKlantnaam', _selectedKlantnaam!);
    }
    if (_selectedProjectnaam != null) {
      await prefs.setString('selectedProjectnaam', _selectedProjectnaam!);
    }

    await prefs.setBool('isClockedIn', isClockedIn);

    if (isClockedIn && startTime != null) {
      await prefs.setInt('clockInTimestamp', startTime);
    } else if (!isClockedIn) {
      await prefs.remove('clockInTimestamp');
    }
  }

  Future<void> handleClockOut() async {
    await _clockOut();
  }

  Future<void> _clockOut() async {
    setState(() {
      isClockedIn = false;
      // We blijven de timer tonen na uitklokken
      _stopWatchTimer.onStopTimer();
      _stopWatchTimer.onResetTimer();
      String timeStamp =
          'Uitgeklokt: ${_formatDateTime(DateTime.now())}';
      timeStamps.add(timeStamp);
      _saveTimeStamps();
    });

    _notificationTimer?.cancel();
    _cancelNotification();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isClockedIn', false);
    await prefs.remove('clockInTimestamp');
  }

  void startNotificationUpdates() {
    _scheduleNotificationUpdates();
  }

  void _scheduleNotificationUpdates() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNotificationWithCurrentTime();
    });
  }

  void _updateNotificationWithCurrentTime() {
    if (!isClockedIn) return;

    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      final startTime = prefs.getInt('clockInTimestamp');
      if (startTime != null) {
        final elapsedTime = DateTime.now().millisecondsSinceEpoch - startTime;
        _showNotification(elapsedTime);
      }
    });
  }

  void _showNotification(int timerValue) async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'clock_in_category',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Clock in',
      channelDescription: 'Notification for clock in and timer running',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'CLOCK_OUT',
          'Uitklokken',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
      fullScreenIntent: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Clock in',
      'Time Clocked In: ${_formatTime(timerValue)}',
      platformChannelSpecifics,
      payload: 'SHOW_CLOCK_IN',
    );
  }

  void _cancelNotification() {
    flutterLocalNotificationsPlugin.cancel(0);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String _formatTime(int rawTime) {
    final int hours = rawTime ~/ 3600000;
    final int minutes = (rawTime % 3600000) ~/ 60000;
    final int seconds = (rawTime % 60000) ~/ 1000;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _showTimer = true; // Toon timer na registratie
        _registrationCompleted = true;
      });
      // Niet meer automatisch inklokken
    }
  }

  void _removeTimeStamp(int index) {
    setState(() {
      timeStamps.removeAt(index);
      _saveTimeStamps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: const Text('Clock In', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/');
          }
        },
        child: Center(
          // Toon timer of registratie op basis van _showTimer
          child: _showTimer ? _buildTimer() : _buildRegistrationForm(),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Registratie',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Klantnaam',
                border: OutlineInputBorder(),
              ),
              value: _selectedKlantnaam,
              items: _klantnamen.map((String klantnaam) {
                return DropdownMenuItem<String>(
                  value: klantnaam,
                  child: Text(klantnaam),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKlantnaam = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecteer een klantnaam' : null,
              onSaved: (value) => _selectedKlantnaam = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Projectnaam',
                border: OutlineInputBorder(),
              ),
              value: _selectedProjectnaam,
              items: _projectnamen.map((String projectnaam) {
                return DropdownMenuItem<String>(
                  value: projectnaam,
                  child: Text(projectnaam),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProjectnaam = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecteer een projectnaam' : null,
              onSaved: (value) => _selectedProjectnaam = value,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRegistration,
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_selectedKlantnaam!} (${_selectedProjectnaam!})',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final rawTime = snapshot.data!;
            final displayTime = _formatTime(rawTime);
            return Text(
              displayTime,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (isClockedIn) {
                  handleClockOut();
                } else {
                  _clockIn();
                }
              },
              icon: Icon(isClockedIn ? Icons.pause : Icons.play_arrow),
              label: Text(isClockedIn ? 'Uitklokken' : 'Inklokken'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                _stopWatchTimer.onResetTimer();
                setState(() {
                  isClockedIn = false;
                });
                // Reset ook de opgeslagen timer status
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isClockedIn', false);
                await prefs.remove('clockInTimestamp');
                // Stop de notificatie updates
                _notificationTimer?.cancel();
                _cancelNotification();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: timeStamps.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(timeStamps[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _removeTimeStamp(index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}