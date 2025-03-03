import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  late String _startTime;

  void _startClockIn() {
    setState(() {
      _startTime = TimeOfDay.now().format(context);
    });

    context.go(
      '/registration-overview',
      extra: _startTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialiseer _startTime hier in plaats van in initState
    _startTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom Peeters'),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[buildHeader(context), buildMenuItems(context)],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registratie',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terug naar 27/02/2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Klantnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: 'Strouwi',
                    items: ['Strouwi'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {},
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Projectnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: 'Buildbase App',
                    items: ['Buildbase App'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {},
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startClockIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text('START', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xff13263B),
      padding: EdgeInsets.only(
        top: 12 + MediaQuery.of(context).padding.top,
        bottom: 12,
      ),
      child: Image.network(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE9nfuUHODaRVxxYt52rm2NbDDOrCd-3_Z3w&s',
        height: 100,
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
            context.go('/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_sharp),
          title: const Text('Calendar'),
          onTap: () {
            Navigator.pop(context);
            context.go('/calendar', extra: "Meeting at 11:30 AM");
          },
        ),
        ListTile(
          leading: const Icon(Icons.access_time_outlined),
          title: const Text('Clock In'),
          onTap: () {
            Navigator.pop(context);
            context.go('/clock-in', extra: 12345);
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text('Profile'),
          onTap: () {
            Navigator.pop(context);
            context.go('/profile/1');
          },
        ),
      ],
    );
  }
}
