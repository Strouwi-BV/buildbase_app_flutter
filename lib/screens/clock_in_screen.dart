import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  bool isClockedIn = false;
  List<String> timeStamps = [];

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
  }

  void _clockIn() {
    setState(() {
      isClockedIn = true;
      _stopWatchTimer.onStartTimer();
      timeStamps.add('Ingeklokt: ${_formatDateTime(DateTime.now())}');
    });
  }

  void _clockOut() {
    setState(() {
      isClockedIn = false;
      _stopWatchTimer.onStopTimer();
      _stopWatchTimer.onResetTimer();
      timeStamps.add('Uitgeklokt: ${_formatDateTime(DateTime.now())}');
    });
  }

  void _removeTimeStamp(int index) {
    setState(() {
      timeStamps.removeAt(index);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String _formatTime(int rawTime) {
    final int hours = rawTime ~/ (1000 * 60 * 60);
    final int minutes = (rawTime ~/ (1000 * 60)) % 60;
    final int seconds = (rawTime ~/ 1000) % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snapshot) {
                  final rawTime = snapshot.data;
                  final displayTime = _formatTime(rawTime!);
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
          ),
        ),
      ),
    );
  }
}
