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
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  bool isClockedIn = false;
  List<String> timeStamps = [];

  // State-variabelen voor registratie
  bool _registrationCompleted = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedKlantnaam;
  String? _selectedProjectnaam;

  // Opties voor de dropdownmenu's
  final List<String> _klantnamen = ['Strouwi', 'Klant B', 'Klant C'];
  final List<String> _projectnamen = ['Buildbase app', 'Project X', 'Project Y'];

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
    // Formatteer datum en tijd zonder milliseconden
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
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
