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
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// Define GoRouterConfig
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
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
        // final int? employeeId = state.extra as int?;
        // return ClockInScreen(employeeId: employeeId ?? 0);
        return ClockInScreen();
      },
    ),
    GoRoute(
      path: '/location/:latitude/:longitude',
      builder: (context, state) {
        final double latitude = double.parse(state.pathParameters['latitude']!);
        final double longitude = double.parse(state.pathParameters['longitude']!);
        return LocationScreen(latitude: latitude, longitude: longitude);
      },
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final int userId = int.parse(state.pathParameters['userId']!);
        // final Map<String, dynamic>? userProfile = state.extra as Map<String, dynamic>?;
        return ProfileScreen(userId: userId);
      },
    ),
  ],
);

