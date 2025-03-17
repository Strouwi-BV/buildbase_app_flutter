import 'package:buildbase_app_flutter/screens/forgot_password_screen.dart';
import 'package:buildbase_app_flutter/screens/menu_screen.dart';
import 'package:buildbase_app_flutter/screens/login_screen.dart';
import 'package:buildbase_app_flutter/screens/add_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';
import '/screens/edit_clockin_screen.dart';
import '/screens/event_details_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/screens/calendar_screen.dart' as calendar; // Importeer CalendarScreen.dart en noem het calendar

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/', // root
      builder: (context, state) => calendar.CalendarScreen(),
      routes: [
        GoRoute(
          path: 'clock-in',
          builder: (context, state) => const ClockInScreen(),
        ),
        GoRoute(
          path: 'add-event',
          builder: (BuildContext context, GoRouterState state) {
            return const AddEventScreen();
          },
        ),
        GoRoute(
          path: 'profile/:userId',
          builder: (context, state) {
            final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
            return ProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: 'change-image',
          builder: (context, state) => ChangeImageScreen(),
        ),
        GoRoute(path: 'menu', builder: (context, state) => const MenuScreen()),
        GoRoute(
          path: 'log-in',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) {
            return const ForgotPasswordScreen();
          },
        ),
        GoRoute(
          path: 'event-details/:eventTitle', // We voegen nu een route parameter toe om het eventId mee te geven
          builder: (context, state) {
            // We halen de Event op uit de state.extra.
            final event = state.extra as calendar.Event; // Gebruik calendar.Event
            // We geven de Event door aan EventDetailsScreen.
            return EventDetailsScreen(event: event);
          },
        ),
        GoRoute(
          path: 'edit-clock-in',
          builder: (context, state) {final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Text("No data");
            }

            final date = data['date'] as DateTime;
            final currentClockIn = data['currentClockIn'] as String;
            final currentClockOut = data['currentClockOut'] as String;
            final currentNotes = data['currentNotes'] as String;

            return EditClockInScreen(
              date: date,
              currentClockIn: currentClockIn,
              currentClockOut: currentClockOut,
              currentNotes: currentNotes,
            );
          },
        ),
      ],
    ),
  ],
);

Widget buildMenuItems(BuildContext context) {
  return Container(
    color: const Color(
      0xff13263B,
    ), // Voeg hier de gewenste achtergrondkleur toe
    child: Column(
      children: [
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.calendar_today_sharp),
          title: const Text('Calendar'),
          onTap: () {
            context.push('/');
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.access_time_outlined),
          title: const Text('Clock In'),
          onTap: () {
            context.push('/clock-in');
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.account_circle),
          title: const Text('Profile'),
          onTap: () {
            context.push('/profile/1');
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          onTap: () {
            context.push('/log-in');
          },
        ),
      ],
    ),
  );
}