import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

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
    _focusedDay = DateTime.now().isBefore(lastDay) ? DateTime.now() : lastDay;
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
          onPressed: () => context.go('/'), // Zelfde methode als in LocationScreen
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/'); // Zelfde methode als in LocationScreen
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
                  _focusedDay = focusedDay.isBefore(lastDay) ? focusedDay : lastDay;
                });
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            ...(_events[_selectedDay] ?? []).map((event) => ListTile(
                  title: Text(event),
                )),
          ],
        ),
      ),
    );
  }
}
