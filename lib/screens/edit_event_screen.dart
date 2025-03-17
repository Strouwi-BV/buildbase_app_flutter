import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/calendar_screen.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  late TextEditingController _locationController;
  late Color _eventColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _locationController = TextEditingController(text: widget.event.location);
    _eventColor = widget.event.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute);
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, picked.hour, picked.minute);
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startTime = DateTime(picked.year, picked.month, picked.day, _startTime.hour, _startTime.minute);
        _endTime = DateTime(picked.year, picked.month, picked.day, _endTime.hour, _endTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final updatedEvent = Event(
                title: _titleController.text,
                description: _descriptionController.text,
                startTime: _startTime,
                endTime: _endTime,
                location: _locationController.text,
                color: _eventColor,
              );
              Navigator.pop(context, updatedEvent);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${_startTime.day}/${_startTime.month}/${_startTime.year}'),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text('Start Time: ${_startTime.hour}:${_startTime.minute.toString().padLeft(2,'0')}'),
              onTap: () => _selectStartTime(context),
            ),
            ListTile(
              title: Text('End Time: ${_endTime.hour}:${_endTime.minute.toString().padLeft(2,'0')}'),
              onTap: () => _selectEndTime(context),
            ),
          ],
        ),
      ),
    );
  }
}