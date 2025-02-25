import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart' as custom_widgets;

class CalendarScreen extends StatefulWidget {
  final String data;

  const CalendarScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EventController _eventController;
  String _currentViewType = 'Month';

  @override
  void initState() {
    super.initState();
    _eventController = EventController();
    _loadEvents();
  }

  void _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> timeStamps = prefs.getStringList('timeStamps') ?? [];
    
    // Create maps to track clock-ins and clock-outs per day
    Map<String, List<String>> clockEvents = {};
    
    // Process all timestamps
    for (String timeStamp in timeStamps) {
      DateTime date = _extractDateFromTimeStamp(timeStamp);
      String dayKey = DateFormat('yyyy-MM-dd').format(date);
      
      if (!clockEvents.containsKey(dayKey)) {
        clockEvents[dayKey] = [];
      }
      clockEvents[dayKey]!.add(timeStamp);
    }

    // Add events for all days in the current month
    DateTime now = DateTime.now();
    DateTime firstDay = DateTime(now.year, now.month, 1);
    DateTime lastDay = DateTime(now.year, now.month + 1, 0);

    for (DateTime date = firstDay; date.isBefore(lastDay.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
      // Skip coloring for weekends
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      // Skip coloring for future dates (except today)
      if (date.isAfter(now) && DateFormat('yyyy-MM-dd').format(date) != DateFormat('yyyy-MM-dd').format(now)) {
        continue;
      }

      String dayKey = DateFormat('yyyy-MM-dd').format(date);
      List<String> events = clockEvents[dayKey] ?? [];
      bool hasClockIn = events.any((e) => e.startsWith('Ingeklokt:'));
      
      CalendarEventData eventData = CalendarEventData(
        date: date,
        title: '', // Empty title as requested
        startTime: date,
        endTime: date.add(Duration(hours: 24)),
        color: hasClockIn ? Colors.green.withOpacity(0.7) : const Color.fromARGB(255, 231, 57, 44).withOpacity(0.7),
        description: events.join('\n'), // Store all events for this day
      );
      _eventController.add(eventData);
    }
    setState(() {});
  }

  DateTime _extractDateFromTimeStamp(String timeStamp) {
    String dateString = timeStamp;

    if (dateString.startsWith('Ingeklokt:')) {
      dateString = dateString.substring('Ingeklokt:'.length);
    } else if (dateString.startsWith('Uitgeklokt:')){
      dateString = dateString.substring('Uitgeklokt:'.length);
    }
    dateString = dateString.trim();
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
  }

  void _createEvent(DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController eventTextController = TextEditingController();
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
                decoration: InputDecoration(hintText: 'Voer evenement details in'),
              ),
              SizedBox(height: 8.0),
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
              onPressed: () {
                if (eventTextController.text.isNotEmpty) {
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
                    _eventController.add(CalendarEventData(
                      date: eventStartDateTime,
                      title: eventTextController.text,
                      startTime: eventStartDateTime,
                      endTime: eventEndDateTime,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
      children: items.map((item) => Center(child: Text(item, style: TextStyle(fontSize: 20)))).toList(),
      controller: FixedExtentScrollController(initialItem: initialItem),
    ),
  );
}

  void _viewEventDetails(CalendarEventData event) {
    // Don't show status for weekends
    if (event.date.weekday == DateTime.saturday || event.date.weekday == DateTime.sunday) {
      return;
    }

    // Don't show status for future dates (except today)
    DateTime now = DateTime.now();
    if (event.date.isAfter(now) && DateFormat('yyyy-MM-dd').format(event.date) != DateFormat('yyyy-MM-dd').format(now)) {
      return;
    }

    String formattedDate = DateFormat('dd-MM-yyyy').format(event.date);
    List<String> events = event.description?.split('\n') ?? [];
    
    // Format clock events
    String clockInTime = 'Niet ingeklokt';
    String clockOutTime = 'Niet uitgeklokt';
    
    for (String event in events) {
      if (event.startsWith('Ingeklokt:')) {
        clockInTime = DateFormat('HH:mm').format(_extractDateFromTimeStamp(event));
      } else if (event.startsWith('Uitgeklokt:')) {
        clockOutTime = DateFormat('HH:mm').format(_extractDateFromTimeStamp(event));
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            formattedDate,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ingeklokt: $clockInTime'),
              SizedBox(height: 8),
              Text('Uitgeklokt: $clockOutTime'),
            ],
          ),
          actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
         style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff13263B),
        foregroundColor: Colors.white,
          ),
       child: Text('Annuleren'),
       onPressed: () => Navigator.of(context).pop(),
        ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff13263B),
                  foregroundColor: Colors.white,
                ),
                child: Text('Bewerk'),
                onPressed: () {
                  context.push('/edit-clock-in', extra: {
                    'date': event.date,
                    'clockInTime': clockInTime,
                    'clockOutTime': clockOutTime,
                  });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: Text('Calendar', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff13263B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              // Gebruik de juiste methode om naar de huidige datum te springen
              _eventController.add(CalendarEventData(
                date: DateTime.now(),
                title: 'Today',
                startTime: DateTime.now(),
                endTime: DateTime.now().add(Duration(hours: 1)), // Voeg een eindtijd toe
              ));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (viewType) {
              setState(() {
                _currentViewType = viewType;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Month',
                child: Text('Maand Kalender'),
              ),
              PopupMenuItem(
                value: 'Week',
                child: Text('Week Kalender'),
              ),
              PopupMenuItem(
                value: 'Day',
                child: Text('Dag Kalender'),
              ),
            ],
            icon: Icon(Icons.view_agenda),
          ),
        ],
      ),
      body: _getCurrentView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createEvent(DateTime.now()),
        child: Icon(Icons.add),
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
