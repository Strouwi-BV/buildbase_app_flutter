import 'package:buildbase_app_flutter/screens/forgot_password_screen.dart';
import 'package:buildbase_app_flutter/screens/menu_screen.dart';
import 'package:buildbase_app_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';
import '/screens/edit_clockin_screen.dart'; // Importeer de EditClockInScreen
import '/screens/event_details_screen.dart'; // Importeer de EventDetailsScreen
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

//bib@bib.be
//Test123
class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
    GoRoute(path: '/', builder: (context, state) => const ClockInScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) {
        final String? data = state.extra as String?;
        return CalendarScreen(data: data ?? "No data here");
      },
    ),
    GoRoute(path: '/clock-in', builder: (context, state) => const ClockInScreen()),
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
    GoRoute(path: '/menu', builder: (context, state) => MenuScreen()),
    GoRoute(
      path: '/log-in',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/event-details',
      builder: (context, state) {
        // Haal de data uit de state.extra
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const Text("No data"); // Toon een error als er geen data is
        }

        // Extract de data
        final formattedDate = data['formattedDate'] as String? ?? "";
        final clockInTime = data['clockInTime'] as String? ?? "";
        final clockOutTime = data['clockOutTime'] as String? ?? "";
        final noteText = data['noteText'] as String? ?? "";
        final location = data['location'] as String? ?? "";
        // Contoleren of de date wel correct is doorgegeven, anders geven we een standaard waarde.
        final date = data['date'] as DateTime;

        return EventDetailsScreen(
          formattedDate: formattedDate,
          clockInTime: clockInTime,
          clockOutTime: clockOutTime,
          noteText: noteText,
          location: location,
          date: date,
        );
      },
    ),
    GoRoute(
      path: '/edit-clock-in',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
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
            context.go('/calendar', extra: "Meeting at 11:30 AM");
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.access_time_outlined),
          title: const Text('Clock In'),
          onTap: () {
            context.go('/clock-in');
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.account_circle),
          title: const Text('Profile'),
          onTap: () {
            context.go('/profile/1');
          },
        ),
        ListTile(
          iconColor: Colors.white,
          textColor: Colors.white,
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          onTap: () {
            context.go('/log-in');
          },
        ),
      ],
    ),
  );
}