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
    setState(() {
      for (String timeStamp in timeStamps) {
        DateTime date = _extractDateFromTimeStamp(timeStamp);
        _eventController.add(CalendarEventData(
          date: date,
          title: timeStamp,
          startTime: date,
          endTime: date.add(Duration(hours: 1)), // Voeg een eindtijd toe
        ));
      }
    });
  }

  DateTime _extractDateFromTimeStamp(String timeStamp) {
    String dateString = timeStamp.split(' ')[0]; // Extract date part
    return DateFormat('yyyy-MM-dd').parse(dateString);
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

  void _viewEventDetails(CalendarEventData event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.title),
          content: Text('Begintijd: ${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime!)}\nEindtijd: ${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime!)}'),
          actions: [
            TextButton(
              child: Text('Sluiten'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
