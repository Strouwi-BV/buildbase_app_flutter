import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Home'),
      drawer: const NavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE9nfuUHODaRVxxYt52rm2NbDDOrCd-3_Z3w&s',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welkom bij Buildbase",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff13263B),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bouw je software pakket naar jouw noden",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildHeader(context), buildMenuItems(context)],
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
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text('LoginTest'),
          onTap: () {
            Navigator.pop(context);
            context.go('/log-in');
          },
        ),
      ],
    );
  }
}
