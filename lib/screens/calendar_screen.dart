import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:buildbase_app_flutter/screens/add_event_screen.dart';
import 'package:buildbase_app_flutter/screens/event_details_screen.dart';
import 'package:buildbase_app_flutter/screens/edit_event_screen.dart';
import 'header_bar_screen.dart';
import 'package:buildbase_app_flutter/model/event_model.dart';

// EventIndicator klasse
class EventIndicator extends StatelessWidget {
  final Event event;

  const EventIndicator({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
      width: 8.0,
      height: 8.0,
    );
  }
}

class EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback onDelete; // Callback om het evenement te verwijderen
  final VoidCallback onEdit;

  const EventTile({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Text(
        '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
      ),
      onTap: onEdit,
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}

// HourTile klasse
class HourTile extends StatelessWidget {
  final String hour;

  const HourTile({Key? key, required this.hour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: Text(hour, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class EventHourTile extends StatelessWidget {
  final Event event;
  final int index;
  final int totalEvents;
  final int dayIndex;
  final CalendarView calendarView;
  final Function(BuildContext, Event) showEventDetails;

  const EventHourTile({
    Key? key,
    required this.event,
    required this.index,
    required this.totalEvents,
    required this.dayIndex,
    required this.calendarView,
    required this.showEventDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startOfDay = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
      0,
      0,
      0,
    );

    final startMinutes = event.startTime.difference(startOfDay).inMinutes;
    final endMinutes = event.endTime.difference(startOfDay).inMinutes;

    final top = startMinutes.toDouble();
    final height = (endMinutes - startMinutes).toDouble();

    // Bepaal de positie en grootte
    double left, width;
    final screenWidth = MediaQuery.of(context).size.width;
    const timeColumnWidth = 50.0;
    final availableWidth = screenWidth - timeColumnWidth;

    if (calendarView == CalendarView.day) {
      // Voor dagweergave: bereken overlappingen en plaats events onder elkaar waar mogelijk
      width = availableWidth * 0.9; // 90% van beschikbare breedte
      left = timeColumnWidth + (availableWidth * 0.05); // 5% marge
    } else {
      // Voor weekweergave: verdeel over de dagen
      width = availableWidth / 7;
      left = timeColumnWidth + (dayIndex * width);
    }

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => showEventDetails(context, event),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            subtitle:
                calendarView == CalendarView.day
                    ? Text(
                      '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                      '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12),
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}

// CalendarScreen klasse
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

// _CalendarScreenState klasse
class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  CalendarView _calendarView = CalendarView.month;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      if (_calendarView == CalendarView.day) {
        final formattedDate = _formatDate(_selectedDay);
        final response = await ApiService().getClockingDayView(formattedDate);
        _events = response.clockings;
      } else if (_calendarView == CalendarView.week) {
        final startOfWeek = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        _events = [];

        // Haal data op voor elke dag van de week
        for (int i = 0; i < 7; i++) {
          final currentDay = startOfWeek.add(Duration(days: i));
          final formattedDate = _formatDate(currentDay);
          try {
            final response = await ApiService().getClockingDayView(
              formattedDate,
            );
            _events.addAll(response.clockings);
          } catch (e) {
            print("Error loading events for $formattedDate: $e");
          }
        }
      } else {
        _events = await ApiService().getClockingMonthView(
          DateTime(_focusedDay.year, _focusedDay.month, 1),
          DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fout bij laden events: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _deleteEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
  }

  void _editEvent(BuildContext context, Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
    );
    if (result is Event) {
      setState(() {
        final index = _events.indexOf(event);
        if (index != -1) {
          _events[index] = result;
        }
      });
    }
  }

  void _showEventDetails(BuildContext context, Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEventScreen(event: event)),
    );

    if (result is Event) {
      _deleteEvent(result);
    } else if (result is String && result == 'edit') {
      _editEvent(context, event);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      if (_calendarView == CalendarView.month) {
        _calendarView = CalendarView.day;
      }
    });
    _fetchEvents(); // Haal nieuwe evenementen op voor de dagweergave
  }

  void _addEvent(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    );

    if (result is Event) {
      setState(() {
        _events.add(result);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return isSameDay(eventDate, day);
    }).toList();
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _calendarView = view;
      if (view == CalendarView.month) {
        _selectedDay = DateTime.now();
      }
    });
    _fetchEvents(); // Haal evenementen op voor de nieuwe weergave
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _fetchEvents(); // Haal evenementen opnieuw op bij pagina wisseling
  }

  List<Event> get _upcomingEvents {
    final now = DateTime.now();
    return List.from(_events.where((event) => event.startTime.isAfter(now)));
  }

  List<List<Event>> _getEventsForWeek(DateTime firstDayOfWeek) {
    List<List<Event>> weekEvents = List.generate(7, (_) => []);

    for (var event in _events) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      for (int i = 0; i < 7; i++) {
        if (isSameDay(eventDate, firstDayOfWeek.add(Duration(days: i)))) {
          weekEvents[i].add(event);
        }
      }
    }

    return weekEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff13263B),
        onPressed: () => _addEvent(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<CalendarView>(
                value: _calendarView,
                onChanged: (CalendarView? newValue) {
                  if (newValue != null) {
                    _onViewChanged(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: CalendarView.month,
                    child: Text('Month'),
                  ),
                  DropdownMenuItem(
                    value: CalendarView.week,
                    child: Text('Week'),
                  ),
                  DropdownMenuItem(value: CalendarView.day, child: Text('Day')),
                ],
              ),
            ],
          ),
          if (_calendarView == CalendarView.month)
            TableCalendar(
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.zero,
                cellAlignment: Alignment.center,
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              calendarFormat: _calendarFormat,
              rowHeight: 100,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: _onPageChanged,
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;

                  final visibleCount = 4; // Aantal bolletjes om te tonen
                  final extraCount = events.length - visibleCount;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Toon eerste X bolletjes
                      ...events
                          .take(visibleCount)
                          .map((e) => EventIndicator(event: e as Event)),
                      // Toon "+X" indicator als er meer zijn
                      if (extraCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 2),
                          child: Text(
                            '+',
                            style: TextStyle(
                              color:
                                  Colors
                                      .grey, // Correcte syntax voor zwarte kleur
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          if (_calendarView == CalendarView.week)
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final firstDayOfWeek = _focusedDay.subtract(
                    Duration(days: _focusedDay.weekday - 1),
                  );
                  final weekEvents = _getEventsForWeek(firstDayOfWeek);
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: 1440, // 24 uur * 60 minuten per uur
                      child: Stack(
                        children: [
                          // Verticale lijnen
                          ...List.generate(7, (index) {
                            return Positioned(
                              top: 0,
                              bottom: 0,
                              left:
                                  50 +
                                  (index *
                                      (MediaQuery.of(context).size.width - 50) /
                                      7),
                              child: Container(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                            );
                          }),
                          // Roosterlijnen
                          ...List.generate(24, (index) {
                            return Positioned(
                              top: index * 60.0,
                              left: 50, // Pas dit aan
                              right: 0,
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            );
                          }),
                          // Uren kolom
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 50,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 24,
                                itemBuilder: (context, index) {
                                  return HourTile(
                                    hour:
                                        '${index.toString().padLeft(2, '0')}:00',
                                  );
                                },
                              ),
                            ),
                          ),
                          // Dagen kolom
                          Positioned(
                            left: 50,
                            top: 0,
                            right: 0,
                            child: Row(
                              children: List.generate(7, (index) {
                                final day = firstDayOfWeek.add(
                                  Duration(days: index),
                                );
                                return Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      '${day.day}/${day.month}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          ...[
                            for (int i = 0; i < 7; i++)
                              for (int j = 0; j < weekEvents[i].length; j++)
                                EventHourTile(
                                  event: weekEvents[i][j],
                                  index: j,
                                  totalEvents: weekEvents[i].length,
                                  dayIndex: i,
                                  calendarView:
                                      _calendarView, // Geef de huidige weergave mee
                                  showEventDetails: _showEventDetails,
                                ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_calendarView == CalendarView.day)
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: 1440, // 24 uur * 60 minuten per uur
                      child: Stack(
                        children: [
                          // Roosterlijnen
                          ...List.generate(24, (index) {
                            return Positioned(
                              top: index * 60.0,
                              left: 50,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            );
                          }),
                          // Uren kolom
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 50,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 24,
                                itemBuilder: (context, index) {
                                  return HourTile(
                                    hour:
                                        '${index.toString().padLeft(2, '0')}:00',
                                  );
                                },
                              ),
                            ),
                          ),
                          ...[
                            for (
                              int i = 0;
                              i < _getEventsForDay(_selectedDay).length;
                              i++
                            )
                              EventHourTile(
                                event: _getEventsForDay(_selectedDay)[i],
                                index: i,
                                totalEvents:
                                    _getEventsForDay(_selectedDay).length,
                                dayIndex: 0,
                                calendarView:
                                    _calendarView, // Geef de huidige weergave mee
                                showEventDetails: _showEventDetails,
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_calendarView == CalendarView.month)
            Expanded(
              child: ListView.builder(
                itemCount: _upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = _upcomingEvents[index];
                  return GestureDetector(
                    onTap: () => _showEventDetails(context, event),
                    child: EventTile(
                      event: event,
                      onDelete: () => _deleteEvent(event),
                      onEdit: () => _editEvent(context, event),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// CalendarView enum
enum CalendarView { month, week, day }
