import 'package:buildbase_app_flutter/screens/menu_screen.dart';
import 'package:buildbase_app_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:buildbase_app_flutter/screens/registration_overview_screen.dart';
import 'package:buildbase_app_flutter/screens/clocking_details_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
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
      GoRoute(
          path: '/clock-in', builder: (context, state) => const ClockInScreen()),
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
          path: '/registration-overview',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return RegistrationOverviewScreen(
                startDate: data['startDate'],
                startTime: data['startTime'],
                endDate: data['endDate'],
                clientName: data['clientName'],
                projectName: data['projectName'],
                date: data['date']);
          }),
      GoRoute(
        path: '/clocking-details',
        builder: (context, state) => const ClockingDetailsScreen(),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

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