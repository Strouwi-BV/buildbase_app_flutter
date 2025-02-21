import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart' as custom_widgets;
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  bool isClockedIn = false;
  List<String> timeStamps = [];
  final _formKey = GlobalKey<FormState>();
  bool _registrationCompleted = false;
  String? _selectedKlantnaam;
  String? _selectedProjectnaam;
  final List<String> _klantnamen = ['Strouwi', 'Klant B', 'Klant C'];
  final List<String> _projectnamen = ['Buildbase app', 'Project X', 'Project Y'];

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

      if (isClockedIn) {
        int clockInTimestamp = prefs.getInt('clockInTimestamp') ?? DateTime.now().millisecondsSinceEpoch;
        int elapsed = DateTime.now().millisecondsSinceEpoch - clockInTimestamp;

        _stopWatchTimer.onStartTimer();
        _scheduleNotificationUpdates();
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

  void _clockIn() {
    setState(() {
      isClockedIn = true;
      _stopWatchTimer.onStartTimer();
      _saveTimerState();
      String timeStamp = 'Ingeklokt: ${_formatDateTime(DateTime.now())}';
      timeStamps.add(timeStamp);
      _saveTimeStamps();
    });

    _scheduleNotificationUpdates();
    // String timeStamp = 'Ingeklokt: ${_formatDateTime(DateTime.now())}';
    // timeStamps.add(timeStamp);
    // _saveTimeStamps();
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedKlantnaam != null ) {
      await prefs.setString('selectedKlantnaam', _selectedKlantnaam!);
    }
    if (_selectedProjectnaam != null ) {
      await prefs.setString('selectedProjectnaam', _selectedProjectnaam!);
    }

    await prefs.setBool('isClockedIn', isClockedIn);

    if (isClockedIn) {
      await prefs.setInt('clockInTimestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  void _clockOut() async {
    setState(() {
      isClockedIn = false;
      _stopWatchTimer.onStopTimer();
      _stopWatchTimer.onResetTimer();
      String timeStamp = 'Uitgeklokt: ${_formatDateTime(DateTime.now())}';
      timeStamps.add(timeStamp);
      _saveTimeStamps();
      
    });

    _notificationTimer?.cancel();
    _cancelNotification();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isClockedIn', false);
  }

  void _scheduleNotificationUpdates() {
    // _stopWatchTimer.rawTime.listen((value) {
    //   _showNotification(value);
    // });
    // _stopWatchTimer.rawTime.listen((value) {
    //   if (isClockedIn) {
    //     _showNotification(value);
    //   }
    // });
    // Timer.periodic(const Duration(seconds: 10), (timer) {
    //   if (!isClockedIn) {
    //     timer.cancel();
    //   } else {
    //     _showNotification(_stopWatchTimer.rawTime.value);
    //   }
    // });
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!isClockedIn) {
        timer.cancel();
      } else {
        final int currentTime = _stopWatchTimer.rawTime.value;
        print("Updating notification with time: $currentTime");
        _showNotification(currentTime);
      }
    });
  }

  void _showNotification(int timerValue) async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails (
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
        AndroidNotificationAction('CLOCK_OUT', 'Uitklokken'),
      ],
      // timeoutAfter: 5000,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Clock in',
      'Time Clocked In: ${_formatTime(timerValue)}',
      platformChannelSpecifics,
      payload: 'CLOCK_OUT',
    );
  }

  void _cancelNotification() {
    flutterLocalNotificationsPlugin.cancel(0);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Datum en tijd
  }

  String _formatTime(int rawTime) {
    final int hours = rawTime ~/ 3600000;
    final int minutes = (rawTime % 3600000) ~/ 60000;
    final int seconds = (rawTime % 60000) ~/ 1000;
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _registrationCompleted = true;
      });
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
          child: _registrationCompleted ? _buildTimer() : _buildRegistrationForm(),
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
              validator: (value) => value == null ? 'Selecteer een klantnaam' : null,
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
              validator: (value) => value == null ? 'Selecteer een projectnaam' : null,
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
                  _clockOut();
                } else {
                  _clockIn();
                }
              },
              icon: Icon(isClockedIn ? Icons.pause : Icons.play_arrow),
              label: Text(isClockedIn ? 'Uitklokken' : 'Inklokken'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _stopWatchTimer.onResetTimer();
                setState(() {
                  isClockedIn = false;
                });
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
