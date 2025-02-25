import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class EditClockInScreen extends StatefulWidget {
  final DateTime date;
  final String currentClockIn;
  final String currentClockOut;
  final String currentNotes;

  EditClockInScreen({
    required this.date,
    required this.currentClockIn,
    required this.currentClockOut,
    required this.currentNotes,
  });

  @override
  _EditClockInScreenState createState() => _EditClockInScreenState();
}

class _EditClockInScreenState extends State<EditClockInScreen> {
  TimeOfDay? _selectedClockInTime;
  TimeOfDay? _selectedClockOutTime;
  late TextEditingController _notesController;

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
    _notesController = TextEditingController(text: widget.currentNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date, TimeOfDay? time) {
    if (time == null) {
      return 'Niet ingegeven';
    }
    DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void _saveClockInOut() async {
    // Sla de klok-in en klok-uit tijden en de notities op in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);
    String clockInTimeStamp = _formatDate(widget.date, _selectedClockInTime);
    String clockOutTimeStamp = _formatDate(widget.date, _selectedClockOutTime);
    String noteText = _notesController.text;

    List<String> timeStamps = prefs.getStringList('timeStamps') ?? [];
    timeStamps.removeWhere((timeStamp) => timeStamp.contains(formattedDate));

    if (clockInTimeStamp != 'Niet ingegeven') {
      timeStamps.add('Ingeklokt: $clockInTimeStamp');
    }
    if (clockOutTimeStamp != 'Niet ingegeven') {
      timeStamps.add('Uitgeklokt: $clockOutTimeStamp');
    }

    if (noteText.isNotEmpty) {
      // Als er notities zijn, voeg ze toe
        timeStamps.add('Notities: $formattedDate - $noteText');

    }
    else {
        // Als er geen notities zijn, zorg ervoor dat er geen oude notities blijven staan
        timeStamps.removeWhere((timeStamp) => timeStamp.contains('Notities: $formattedDate'));
    }

    await prefs.setStringList('timeStamps', timeStamps);
    // Geef de bijgewerkte tijden terug aan de CalendarScreen
    context.pop(true);
    context.pop();
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
                        ? '${_selectedClockInTime!.hour.toString().padLeft(2, '0')}:${_selectedClockInTime!.minute.toString().padLeft(2, '0')}'
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
                        ? '${_selectedClockOutTime!.hour.toString().padLeft(2, '0')}:${_selectedClockOutTime!.minute.toString().padLeft(2, '0')}'
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
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notities',
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Maak er een box veld van
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
              },
            ),
          ],
        ),
      ),
    );
  }
}