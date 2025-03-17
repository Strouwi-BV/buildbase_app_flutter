import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/calendar_screen.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  String? _selectedLocation;
  Color _selectedColor = Colors.blue; // Default color

  void _addEvent(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Maak een nieuw evenement
      DateTime startDateTime = DateTime(_selectedStartDate.year, _selectedStartDate.month, _selectedStartDate.day, _selectedStartTime.hour, _selectedStartTime.minute);
      DateTime endDateTime = DateTime(_selectedEndDate.year, _selectedEndDate.month, _selectedEndDate.day, _selectedEndTime.hour, _selectedEndTime.minute);
      final newEvent = Event(title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _selectedLocation,
        color: _selectedColor, // Gebruik de geselecteerde kleur
      );
      // Sluit het scherm en geef het nieuwe evenement door aan het vorige scherm
      Navigator.of(context).pop(newEvent);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = pickedDate;
        } else {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime : _selectedEndTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = pickedTime;
        } else {
          _selectedEndTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                        'Start Date: ${_selectedStartDate.toLocal().toString().split(' ')[0]}'),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text('Start Time: ${_selectedStartTime.format(context)}'),
                  ),
                  TextButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text('End Time: ${_selectedEndTime.format(context)}'),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                        'End Date: ${_selectedEndDate.toLocal().toString().split(' ')[0]}'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                onChanged: (newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'Office', child: Text('Office')),
                  DropdownMenuItem(value: 'Home', child: Text('Home')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                decoration: const InputDecoration(labelText: 'Location'),
              ),
               // Color picker
              Row(
                children: [
                  const Text('Color: '),
                  DropdownButton<Color>(
                    value: _selectedColor,
                    items: const [
                      DropdownMenuItem(value: Colors.blue, child: CircleAvatar(backgroundColor: Colors.blue)),
                      DropdownMenuItem(value: Colors.red, child: CircleAvatar(backgroundColor: Colors.red)),
                      DropdownMenuItem(value: Colors.green, child: CircleAvatar(backgroundColor: Colors.green)),
                      DropdownMenuItem(value: Colors.yellow, child: CircleAvatar(backgroundColor: Colors.yellow)),
                    ],
                    onChanged: (value) {
                      setState(() {                        _selectedColor = value!;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _addEvent(context),
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}