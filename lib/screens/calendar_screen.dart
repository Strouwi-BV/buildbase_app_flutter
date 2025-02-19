import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String data;

  const CalendarScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<String>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> timeStamps = prefs.getStringList('timeStamps') ?? [];
    setState(() {
      _events = _groupEventsByDate(timeStamps);
    });
  }

  Map<DateTime, List<String>> _groupEventsByDate(List<String> timeStamps) {
    Map<DateTime, List<String>> events = {};
    for (String timeStamp in timeStamps) {
      DateTime date = _extractDateFromTimeStamp(timeStamp);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(timeStamp);
    }
    return events;
  }

  DateTime _extractDateFromTimeStamp(String timeStamp) {
    String dateString = timeStamp.split(' ')[0]; // Extract date part
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  DateTime get firstDay => DateTime(2022);
  DateTime get lastDay => DateTime(2026);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'), // Navigatie terug naar home
        ),
        actions: [
          PopupMenuButton<CalendarFormat>(
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Maand Kalender'),
              ),
              PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week Kalender'),
              ),
            ],
            icon: Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/'); // Navigatie terug naar home
          }
        },
        child: Column(
          children: [
            TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    List<String> selectedDayEvents = _events[_selectedDay] ?? [];
    if (selectedDayEvents.isEmpty) {
      return Center(child: Text('Geen evenementen voor deze dag.'));
    } else {
      return ListView.builder(
        itemCount: selectedDayEvents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedDayEvents[index]),
          );
        },
      );
    }
  }
}
