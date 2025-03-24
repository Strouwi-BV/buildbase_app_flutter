import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/calendar_screen.dart';
import 'package:buildbase_app_flutter/model/event_model.dart';

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
  Color _selectedColor = Colors.blue;

  void _addEvent(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      DateTime startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );
      DateTime endDateTime = DateTime(
        _selectedEndDate.year,
        _selectedEndDate.month,
        _selectedEndDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );
      final newEvent = Event(
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _selectedLocation,
        color: _selectedColor,
      );
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
        backgroundColor: const Color(0xff13263B),
        title: const Text('Add Event', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter a title'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Start Date: ${_selectedStartDate.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: Text(
                      'Start Time: ${_selectedStartTime.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, true),
                  ),
                  ListTile(
                    title: Text(
                      'End Date: ${_selectedEndDate.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  ListTile(
                    title: Text(
                      'End Time: ${_selectedEndTime.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, false),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    onChanged:
                        (newValue) =>
                            setState(() => _selectedLocation = newValue),
                    items: const [
                      DropdownMenuItem(value: 'Office', child: Text('Office')),
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Select Color'),
                    trailing: CircleAvatar(backgroundColor: _selectedColor),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Pick a color'),
                              content: Wrap(
                                children:
                                    [
                                      Colors.blue,
                                      Colors.red,
                                      Colors.green,
                                      Colors.yellow,
                                    ].map((color) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => _selectedColor = color,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: CircleAvatar(
                                            backgroundColor: color,
                                            radius: 15,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff13263B),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _addEvent(context),
                      child: const Text('Add Event'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
