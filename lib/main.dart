import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => ClockInScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) {
        final String? data = state.extra as String?;
        return CalendarScreen(data: data ?? "No data here");
      },
    ),
    GoRoute(path: '/clock-in', builder: (context, state) => ClockInScreen()),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
        return ProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/change-image',
      builder: (context, state) => ChangeImageScreen(),
    ),
  ],
);

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
          context.go('/clock-in');
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
