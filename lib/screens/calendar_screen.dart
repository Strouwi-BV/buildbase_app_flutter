import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:buildbase_app_flutter/screens/add_event_screen.dart';
import 'package:buildbase_app_flutter/screens/event_details_screen.dart';
import 'package:buildbase_app_flutter/screens/edit_event_screen.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';

// Event klasse
class Event {
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  Color color; // Maak de kleur aanpasbaar

  Event({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.color = Colors.blue,
  });

  /*************  ✨ Codeium Command ⭐  *************/
  /******  0ec63dc3-77de-4a76-9f28-7c9d0e35267e  *******/
  bool overlapsWith(Event other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }
}

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

// EventTile klasse
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
      title: Text(event.title),
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
  final int dayIndex; // Nieuwe property om de dagindex door te geven
  final CalendarView
  calendarView; // Nieuwe property om de kalenderweergave door te geven
  final Function(BuildContext, Event)
  showEventDetails; // Callback functie voor het tonen van de event details

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
    );
    final startMinutes = event.startTime.difference(startOfDay).inMinutes;
    final endMinutes = event.endTime.difference(startOfDay).inMinutes;
    const totalMinutesInDay = 24 * 60; // 1440

    final top = (startMinutes / totalMinutesInDay) * 1440;
    final height = ((endMinutes - startMinutes) / totalMinutesInDay) * 1440;

    // Bepaal de breedte per evenement
    double widthPerEvent;
    double left;
    if (calendarView == CalendarView.day) {
      // In dagweergave: verdeel de breedte over de overlappende evenementen
      widthPerEvent = (MediaQuery.of(context).size.width - 50) / totalEvents;
      left = 50 + (index * widthPerEvent);
    } else {
      // In weekweergave: verdeeld over de week
      widthPerEvent =
          (MediaQuery.of(context).size.width - 50) / (totalEvents * 7);
      left =
          50 +
          (index * widthPerEvent) +
          (dayIndex * (MediaQuery.of(context).size.width - 50) / 7);
    }

    return Positioned(
      top: top,
      left: left,
      width: widthPerEvent,
      height: height,
      child: GestureDetector(
        onTap: () {
          showEventDetails(context, event);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(
              event.title,
              style: TextStyle(
                fontSize: calendarView == CalendarView.day ? 14 : 10,
              ), // Grotere tekst in dagweergave
            ),
            subtitle:
                calendarView == CalendarView.day
                    ? Text(
                      '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12),
                    )
                    : null, // Geen subtitel in weekweergave
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

  List<Event> _getEventsForDay(DateTime day) {
    final List<Event> dayEvents = [];
    for (var event in _events) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      if (isSameDay(eventDate, day)) {
        dayEvents.add(event);
      }
    }

    // Sorteer de evenementen op starttijd
    dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Splits overlappende evenementen op in groepen
    List<List<Event>> eventGroups = [];
    List<Event> currentGroup = [];

    for (var i = 0; i < dayEvents.length; i++) {
      bool added = false;
      for (var j = 0; j < eventGroups.length; j++) {
        bool overlaps = false;
        for (var k = 0; k < eventGroups[j].length; k++) {
          if (dayEvents[i].overlapsWith(eventGroups[j][k])) {
            overlaps = true;
            break;
          }
        }
        if (!overlaps) {
          eventGroups[j].add(dayEvents[i]);
          added = true;
          break;
        }
      }
      if (!added) {
        eventGroups.add([dayEvents[i]]);
      }
    }

    // Organiseer evenementen per tijdslot
    List<Event> organizedEvents = [];
    for (var group in eventGroups) {
      for (var event in group) {
        organizedEvents.add(event);
      }
    }

    return organizedEvents;
  }

  List<List<Event>> _getEventsForWeek(DateTime firstDayOfWeek) {
    List<List<Event>> weekEvents = [];
    for (int i = 0; i < 7; i++) {
      final currentDay = firstDayOfWeek.add(Duration(days: i));
      List<Event> dayEvents = [];
      for (var event in _events) {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        if (isSameDay(eventDate, currentDay)) {
          dayEvents.add(event);
        }
      }

      // Sorteer de evenementen op starttijd
      dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Splits overlappende evenementen op in groepen
      List<List<Event>> eventGroups = [];
      List<Event> currentGroup = [];

      for (var i = 0; i < dayEvents.length; i++) {
        bool added = false;
        for (var j = 0; j < eventGroups.length; j++) {
          bool overlaps = false;
          for (var k = 0; k < eventGroups[j].length; k++) {
            if (dayEvents[i].overlapsWith(eventGroups[j][k])) {
              overlaps = true;
              break;
            }
          }
          if (!overlaps) {
            eventGroups[j].add(dayEvents[i]);
            added = true;
            break;
          }
        }
        if (!added) {
          eventGroups.add([dayEvents[i]]);
        }
      }

      // Organiseer evenementen per tijdslot
      List<Event> organizedEvents = [];
      for (var group in eventGroups) {
        for (var event in group) {
          organizedEvents.add(event);
        }
      }

      weekEvents.add(organizedEvents);
    }
    return weekEvents;
  }

  List<Event> get _upcomingEvents {
    final now = DateTime.now();
    return List.from(_events.where((event) => event.startTime.isAfter(now)));
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

  void _deleteEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
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
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _calendarView = view;
      if (view == CalendarView.month) {
        _selectedDay = DateTime.now();
      }
    });
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
                // Hier verwijderen we de filters
                cellMargin: EdgeInsets.zero,
                cellAlignment: Alignment.center,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // Verberg de knop voor de weergave
              ),
              calendarFormat: _calendarFormat,
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
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          events
                              .map((e) => EventIndicator(event: e as Event))
                              .toList(),
                    );
                  }
                  return null;
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
