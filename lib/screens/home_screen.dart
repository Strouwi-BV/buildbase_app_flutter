import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text("Home")),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           ElevatedButton(
  //             onPressed: () {
  //               context.go('/calendar', extra: "Meeting at 11:30 AM");
  //             },
  //             child: Text("Go to Calendar"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               context.go('/clock-in', extra: 12345);
  //             },
  //             child: Text("Clock In")
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               context.go('/location/37.7749/-122.4194'); //example coords
  //             },
  //             child: Text("Go to Location"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               context.go('/profile/1');
  //             },
  //             child: Text("Go to Profile"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        "Home",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xff13263B),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    drawer: const NavigationDrawer(),
  );
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key); //hier is een fout

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
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

  Widget buildMenuItems(BuildContext context) => Column(
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
        leading: const Icon(Icons.location_on),
        title: const Text('Location'),
        onTap: () {
          Navigator.pop(context);
          context.go('/location/37.7749/-122.4194');
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
          context.go('/profile', extra: {"name": "John Doe", "age": 30});
        },
      ),
    ],
  );
}