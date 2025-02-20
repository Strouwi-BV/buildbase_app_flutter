import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/location_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

// Define GoRouterConfig
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) {
        final String? data = state.extra as String?;
        return CalendarScreen(data: data ?? "No data here");
      },
    ),
    GoRoute(
      path: '/clock-in',
      builder: (context, state) {
        return ClockInScreen();
      },
    ),
    GoRoute(
      path: '/location/:latitude/:longitude',
      builder: (context, state) {
        return LocationScreen();
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final Map<String, dynamic>? userProfile =
            state.extra as Map<String, dynamic>?;
        return ProfileScreen(
          userProfile: userProfile ?? {"name": "Guest", "age": 0},
        );
      },
    ),
  ],
);
