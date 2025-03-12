import 'package:flutter/material.dart';
import 'header_bar_screen.dart';
import 'package:go_router/go_router.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  late String _startTime;
  late String _endTime;
  String _selectedClient = 'Strouwi'; // Default values
  String _selectedProject = 'Buildbase App';
  List<String> _clientNames = ['Strouwi', 'Client 2', 'Client 3'];
  List<String> _projectNames = ['Buildbase App', 'Project 2', 'Project 3'];

  void _startClockIn() {
    setState(() {
      _startTime = TimeOfDay.now().format(context);
      _endTime = TimeOfDay.now().format(context);
    });

    // Navigate to RegistrationOverviewScreen and pass the selected values
    context.go(
      '/registration-overview',
      extra: {
        'startTime': _startTime,
        'clientName': _selectedClient,
        'projectName': _selectedProject,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().toIso8601String(),
        'endTime': _endTime,
        'date': '27/02/2025' // You can make this dynamic
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _startTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: const HeaderBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registratie',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terug naar 27/02/2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Klantnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedClient,
                    items: _clientNames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClient = newValue!;
                      });
                    },
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Projectnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedProject,
                    items: _projectNames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProject = newValue!;
                      });
                    },
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startClockIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text('START', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}