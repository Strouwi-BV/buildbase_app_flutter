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
    _selectedClockInTime =
        widget.currentClockIn != 'Niet ingeklokt'
            ? TimeOfDay(
              hour: int.parse(widget.currentClockIn.split(':')[0]),
              minute: int.parse(widget.currentClockIn.split(':')[1]),
            )
            : null;
    _selectedClockOutTime =
        widget.currentClockOut != 'Niet uitgeklokt'
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
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void _saveClockInOut() async {
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
      timeStamps.add('Notities: $formattedDate - $noteText');
    } else {
      timeStamps.removeWhere(
        (timeStamp) => timeStamp.contains('Notities: $formattedDate'),
      );
    }

    await prefs.setStringList('timeStamps', timeStamps);
    context.pop(true);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bewerk klokken',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff13263B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Datum: ${widget.date.day}-${widget.date.month}-${widget.date.year}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTimeRow('Ingeklokt', _selectedClockInTime, (time) {
                      setState(() => _selectedClockInTime = time);
                    }),
                    Divider(),
                    _buildTimeRow('Uitgeklokt', _selectedClockOutTime, (time) {
                      setState(() => _selectedClockOutTime = time);
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notities',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff13263B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Opslaan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveClockInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay?) onTimeSelected,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(
              time != null
                  ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                  : 'Niet opgegeven',
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.access_time, color: Colors.black),
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: time ?? TimeOfDay.now(),
                );
                if (selectedTime != null) {
                  onTimeSelected(selectedTime);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
