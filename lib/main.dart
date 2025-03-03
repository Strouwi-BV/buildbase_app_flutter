import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/home_screen.dart';
import 'package:buildbase_app_flutter/screens/change_image_screen.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:buildbase_app_flutter/screens/registration_overview_screen.dart'; // Importeer hier je nieuwe scherm

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      path: '/profile/:userId',
      builder: (context, state) {
        final int userId = int.parse(state.pathParameters['userId']!);
        return ProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/change-image',
      builder: (context, state) {
        return const ChangeImageScreen();
      },
    ),
    GoRoute(
      path: '/registration-overview', // Voeg de nieuwe route hier toe
      builder: (context, state) {
        final String? startTime = state.extra as String?;
        return RegistrationOverviewScreen(
          startTime: startTime ?? '',
          startDate: DateTime.now().toIso8601String(),
          endDate: DateTime.now().toIso8601String(),
          endTime: '17:00',
          clientName: 'Default Client',
          projectName: 'Default Project',
        ); // Zet de starttijd door naar je nieuwe scherm
      },
    ),
  ],
);
