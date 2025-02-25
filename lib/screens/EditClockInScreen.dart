import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditClockInScreen extends StatefulWidget {
  final DateTime date;
  final String currentClockIn;
  final String currentClockOut;

  EditClockInScreen({
    required this.date,
    required this.currentClockIn,
    required this.currentClockOut,
  });

  @override
  _EditClockInScreenState createState() => _EditClockInScreenState();
}

class _EditClockInScreenState extends State<EditClockInScreen> {
  TimeOfDay? _selectedClockInTime;
  TimeOfDay? _selectedClockOutTime;
  String _notities = '';

  @override
  void initState() {
    super.initState();
    _selectedClockInTime = widget.currentClockIn != 'Niet ingeklokt'
        ? TimeOfDay(
            hour: int.parse(widget.currentClockIn.split(':')[0]),
            minute: int.parse(widget.currentClockIn.split(':')[1]),
          )
        : null;
    _selectedClockOutTime = widget.currentClockOut != 'Niet uitgeklokt'
        ? TimeOfDay(
            hour: int.parse(widget.currentClockOut.split(':')[0]),
            minute: int.parse(widget.currentClockOut.split(':')[1]),
          )
        : null;
  }

  void _saveClockInOut() {
    // Voorbeeldfunctie om de klok-in en klok-uit tijden op te slaan
    final clockInTime = _selectedClockInTime != null
        ? '${_selectedClockInTime!.hour}:${_selectedClockInTime!.minute}'
        : 'Niet ingeklokt';
    final clockOutTime = _selectedClockOutTime != null
        ? '${_selectedClockOutTime!.hour}:${_selectedClockOutTime!.minute}'
        : 'Niet uitgeklokt';

    print('Opgeslagen klok-in tijd: $clockInTime');
    print('Opgeslagen klok-uit tijd: $clockOutTime');
    print('Notities: $_notities');

    // Hier kunt u de logica implementeren om deze gegevens op te slaan in uw kalender of database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bewerk klokken'),
        backgroundColor: Color(0xff13263B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16), // Extra witruimte boven de datum
            Center(
              child: Text(
                'Datum: ${widget.date.day}-${widget.date.month}-${widget.date.year}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16), // Extra witruimte onder de datum
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Ingeklokt:'),
                    SizedBox(width: 16),
                    Text(_selectedClockInTime != null
                        ? '${_selectedClockInTime!.hour}:${_selectedClockInTime!.minute}'
                        : 'Niet ingeklokt'),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () async {
                        final TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedClockInTime ?? TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _selectedClockInTime = selectedTime;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8), // Verminderde witruimte tussen ingeklokt en uitgeklokt
                Row(
                  children: [
                    Text('Uitgeklokt:'),
                    SizedBox(width: 16),
                    Text(_selectedClockOutTime != null
                        ? '${_selectedClockOutTime!.hour}:${_selectedClockOutTime!.minute}'
                        : 'Niet uitgeklokt'),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () async {
                        final TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedClockOutTime ?? TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _selectedClockOutTime = selectedTime;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Notities',
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Maak er een box veld van
              onChanged: (value) {
                setState(() {
                  _notities = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff13263B),
                foregroundColor: Colors.white,
              ),
              child: Text('Opslaan'),
              onPressed: () {
                _saveClockInOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
