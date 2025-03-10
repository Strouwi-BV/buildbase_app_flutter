import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../screens/edit_clockin_screen.dart'; // Import aangepast
import '../screens/event_details_screen.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatefulWidget {
  final String data;

  const CalendarScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EventController _eventController;
  String _currentViewType = 'Month';
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _eventController =
        EventController()..addListener(() {
          setState(() {});
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Laad de evenementen opnieuw wanneer de afhankelijkheden van de widget veranderen
    _loadEvents();
  }

  void _updateCalendar() {
    _loadEvents();
    _eventController.notifyListeners();
  }

  void _loadEvents() async {
    if (_isDialogShown) {
      Navigator.of(context).pop();
      _isDialogShown = false;
    }
    _eventController.removeWhere((event) => true);
    final prefs = await SharedPreferences.getInstance();
    List<String> timeStamps = prefs.getStringList('timeStamps') ?? [];

    // Create maps to track clock-ins and clock-outs per day and notes
    Map<String, List<String>> clockEvents = {};
    Map<String, String> notes = {};

    // Process all timestamps
    for (String timeStamp in timeStamps) {
      DateTime date = _extractDateFromTimeStamp(timeStamp);
      String dayKey = DateFormat('yyyy-MM-dd').format(date);
      if (timeStamp.startsWith('Notities:')) {
        // Store notes separately with dayKey
        notes[dayKey] = timeStamp.split('- ')[1];
      } else {
        // Store other events per day
        if (!clockEvents.containsKey(dayKey)) {
          clockEvents[dayKey] = [];
        }
        clockEvents[dayKey]!.add(timeStamp);
      }
    }
    // Add events for all days in the current month
    DateTime now = DateTime.now();
    DateTime firstDay = DateTime(now.year, now.month, 1);
    DateTime lastDay = DateTime(now.year, now.month + 1, 0);

    for (
      DateTime date = firstDay;
      date.isBefore(lastDay.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))
    ) {
      String dayKey = DateFormat('yyyy-MM-dd').format(date);
      List<String> events = clockEvents[dayKey] ?? [];
      bool hasClockIn = events.any((e) => e.startsWith('Ingeklokt:'));
      // Check for notes for this day
      String note = notes[dayKey] ?? '';

      // Skip coloring for weekends
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      // Skip coloring for future dates (except today)
      if (date.isAfter(now) &&
          DateFormat('yyyy-MM-dd').format(date) !=
              DateFormat('yyyy-MM-dd').format(now)) {
        continue;
      }

      CalendarEventData eventData = CalendarEventData(
        date: date,
        title: '', // Empty title as requested
        startTime: date,
        endTime: date.add(Duration(hours: 24)),
        color:
            hasClockIn
                ? Colors.green.withOpacity(0.7)
                : const Color.fromARGB(255, 231, 57, 44).withOpacity(0.7),
        description: events.join('\n'), // Store all events for this day
      );
      _eventController.add(eventData);
    }
  }

  DateTime _extractDateFromTimeStamp(String timeStamp) {
    String dateString = timeStamp;

    if (dateString.startsWith('Ingeklokt:')) {
      dateString = dateString.substring('Ingeklokt:'.length);
    } else if (dateString.startsWith('Uitgeklokt:')) {
      dateString = dateString.substring('Uitgeklokt:'.length);
    } else if (timeStamp.startsWith('Notities:')) {
      // Als de string begint met 'Notities:', extraheer de datum
      List<String> parts = timeStamp.split(' - ');
      if (parts.length >= 2) {
        dateString = parts[0].substring('Notities: '.length);
      }
    }

    dateString = dateString.trim();
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    }
  }

  void _createEvent(DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController eventTextController = TextEditingController();
        TextEditingController noteTextController = TextEditingController();
        DateTime selectedDate = date;
        TimeOfDay selectedStartTime = TimeOfDay.now();
        TimeOfDay selectedEndTime = TimeOfDay.now();

        return AlertDialog(
          title: Text('Nieuw evenement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventTextController,
                decoration: InputDecoration(
                  hintText: 'Voer evenement details in',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: noteTextController,
                decoration: InputDecoration(hintText: 'Voer notitie in'),
              ),
              TextButton(
                child: Text('Kies Datum'),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              TextButton(
                child: Text('Kies Begintijd'),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedStartTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedStartTime = pickedTime;
                    });
                  }
                },
              ),
              TextButton(
                child: Text('Kies Eindtijd'),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedEndTime = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuleren'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Opslaan'),
              onPressed: () async {
                if (eventTextController.text.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(selectedDate);
                  String noteText = noteTextController.text;
                  String clockInTimeStamp = _formatDate(
                    selectedDate,
                    selectedStartTime,
                  );
                  String clockOutTimeStamp = _formatDate(
                    selectedDate,
                    selectedEndTime,
                  );
                  List<String> timeStamps =
                      prefs.getStringList('timeStamps') ?? [];
                  timeStamps.removeWhere(
                    (timeStamp) => timeStamp.contains(formattedDate),
                  );
                  if (clockInTimeStamp != "Niet ingegeven") {
                    timeStamps.add('Ingeklokt: $clockInTimeStamp');
                  }
                  if (clockOutTimeStamp != "Niet ingegeven") {
                    timeStamps.add('Uitgeklokt: $clockOutTimeStamp');
                  }

                  if (noteText.isNotEmpty) {
                    timeStamps.add('Notities: $formattedDate - $noteText');
                  }
                  await prefs.setStringList('timeStamps', timeStamps);
                  DateTime eventStartDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedStartTime.hour,
                    selectedStartTime.minute,
                  );
                  DateTime eventEndDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  );
                  setState(() {
                    _eventController.add(
                      CalendarEventData(
                        date: eventStartDateTime,
                        title: eventTextController.text,
                        startTime: eventStartDateTime,
                        endTime: eventEndDateTime,
                      ),
                    );
                  });
                  _updateCalendar();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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

  Widget _buildWheelPicker({
    required List<String> items,
    required int initialItem,
    required Function(int) onChanged,
  }) {
    return Container(
      height: 100,
      width: 50,
      child: ListWheelScrollView(
        itemExtent: 40,
        diameterRatio: 1.5,
        useMagnifier: true,
        magnification: 1.3,
        onSelectedItemChanged: onChanged,
        children:
            items
                .map(
                  (item) =>
                      Center(child: Text(item, style: TextStyle(fontSize: 20))),
                )
                .toList(),
        controller: FixedExtentScrollController(initialItem: initialItem),
      ),
    );
  }

  void _viewEventDetails(CalendarEventData event) async {
    // Don't show status for weekends
    if (event.date.weekday == DateTime.saturday ||
        event.date.weekday == DateTime.sunday) {
      return;
    }

    // Don't show status for future dates (except today)
    DateTime now = DateTime.now();
    if (event.date.isAfter(now) &&
        DateFormat('yyyy-MM-dd').format(event.date) !=
            DateFormat('yyyy-MM-dd').format(now)) {
      return;
    }

    String formattedDate = DateFormat('dd-MM-yyyy').format(event.date);
    List<String> events = event.description?.split('\n') ?? [];

    // Format clock events
    String clockInTime = 'Niet ingeklokt';
    String clockOutTime = 'Niet uitgeklokt';
    String noteText = '';
    String location = '';

    List<String> clockInEvents =
        events.where((event) => event.startsWith('Ingeklokt:')).toList();
    List<String> clockOutEvents =
        events.where((event) => event.startsWith('Uitgeklokt:')).toList();
    String dayKey = DateFormat('yyyy-MM-dd').format(event.date);

    final prefs = await SharedPreferences.getInstance();
    List<String> timeStamps = prefs.getStringList('timeStamps') ?? [];
    String noteKey = "Notities: $dayKey";
    String fullNote = timeStamps.firstWhere(
      (element) => element.startsWith(noteKey),
      orElse: () => "",
    );
    if (fullNote.isNotEmpty) {
      noteText = fullNote.substring(noteKey.length + 3);
    }
    if (clockInEvents.isNotEmpty) {
      clockInTime = DateFormat(
        'HH:mm',
      ).format(_extractDateFromTimeStamp(clockInEvents.first));
    } else {
      clockInTime = 'Niet ingeklokt';
    }
    if (clockOutEvents.isNotEmpty) {
      clockOutTime = DateFormat(
        'HH:mm',
      ).format(_extractDateFromTimeStamp(clockOutEvents.first));
    } else {
      clockOutTime = "Niet uitgeklokt";
    }

    location = prefs.getString('currentLocation') ?? "Geen locatie beschikbaar";

    context.push(
      '/event-details',
      extra: {
        'formattedDate': formattedDate,
        'clockInTime': clockInTime,
        'clockOutTime': clockOutTime,
        'noteText': noteText, // Gebruik noteText in plaats van notes
        'location': location,
        'date': event.date, // Voeg de date parameter toe
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              // Gebruik de juiste methode om naar de huidige datum te springen
              _eventController.add(
                CalendarEventData(
                  date: DateTime.now(),
                  title: 'Today',
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(Duration(hours: 1)),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (viewType) {
              setState(() {
                _currentViewType = viewType;
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'Month', child: Text('Maand Kalender')),
                  PopupMenuItem(value: 'Week', child: Text('Week Kalender')),
                  PopupMenuItem(value: 'Day', child: Text('Dag Kalender')),
                ],
            icon: Icon(Icons.view_agenda),
          ),
        ],
      ),
      body: _getCurrentView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createEvent(DateTime.now()),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xff13263B), // Correcte syntax
      ),
    );
  }

  Widget _getCurrentView() {
    switch (_currentViewType) {
      case 'Week':
        return WeekView(
          controller: _eventController,
          onEventTap: (events, date) {
            _viewEventDetails(events.first);
          },
        );
      case 'Day':
        return DayView(
          controller: _eventController,
          onEventTap: (events, date) {
            _viewEventDetails(events.first);
          },
        );
      case 'Month':
      default:
        return MonthView(
          controller: _eventController,
          onCellTap: (events, date) {
            if (events.isNotEmpty) {
              _viewEventDetails(events.first);
            } else {
              _createEvent(date);
            }
          },
        );
    }
  }
}
