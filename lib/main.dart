import 'package:buildbase_app_flutter/screens/forgot_password_screen.dart';
import 'package:buildbase_app_flutter/screens/live_clocking_location.dart';
import 'package:buildbase_app_flutter/screens/menu_screen.dart';
import 'package:buildbase_app_flutter/screens/login_screen.dart';
import 'package:buildbase_app_flutter/screens/registration_overview_screen.dart';
import 'package:buildbase_app_flutter/screens/settings_screen.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:buildbase_app_flutter/service/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final secure = SecureStorageService();
  String? locationEnabled = await secure.readData('location_enabled');

  if (locationEnabled != 'true') {
    await Geolocator.requestPermission();
  }

  runApp(ChangeNotifierProvider(
    create: (context) => TimerProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
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
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
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
      path: '/settings',
      builder: (context, state) {
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/live-clocking-location',
      builder: (context, state) {
        return const LiveClockingLocationScreen();
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
  ],
);

Widget buildMenuItems(BuildContext context, String currentRoute) {
  return Container(
    color: const Color(0xff13263B),
    padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
    child: Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.calendar_today_sharp,
          title: 'Calendar',
          route: '/calendar',
          isActive: currentRoute == '/calendar',
        ),
        _buildMenuItem(
          context,
          icon: Icons.access_time_outlined,
          title: 'Clock In',
          route: '/clock-in',
          isActive: currentRoute == '/clock-in',
        ),
        _buildMenuItem(
          context,
          icon: Icons.account_circle,
          title: 'Profile',
          route: '/profile/1',
          isActive: currentRoute.startsWith('/profile'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.login,
          title: 'Login',
          route: '/log-in',
          isActive: currentRoute == '/log-in',
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          route: '/settings',
          isActive: currentRoute == '/settings',
        ),
        _buildMenuItem(
          context,
          icon: Icons.location_on,
          title: 'Live Clocking Location',
          route: '/live-clocking-location',
          isActive: currentRoute == '/live-clocking-location',
        ),
      ],
    ),
  );
}

Widget _buildMenuItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String route,
  required bool isActive,
}) {
  return ListTile(
    iconColor: isActive ? const Color(0xFFc1ffbf) : Colors.white,
    textColor: isActive ? const Color(0xFFc1ffbf) : Colors.white,
    leading: Icon(icon),
    title:
        isActive
            ? Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFc1ffbf), width: 2),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
            : Text(title),
    onTap: () {
      context.go(route);
    },
  );
}