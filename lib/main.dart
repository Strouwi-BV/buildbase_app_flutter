import 'dart:convert';

import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/screens/forgot_password_screen.dart';
import 'package:buildbase_app_flutter/screens/live_clocking_location.dart';
import 'package:buildbase_app_flutter/screens/menu_screen.dart';
import 'package:buildbase_app_flutter/screens/login_screen.dart';
import 'package:buildbase_app_flutter/screens/registration_overview_screen.dart';
import 'package:buildbase_app_flutter/screens/settings_screen.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:buildbase_app_flutter/service/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/change_image_screen.dart';
import '/screens/edit_clockin_screen.dart';
import '/screens/event_details_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/screens/calendar_screen.dart'
    as calendar; // Importeer CalendarScreen.dart en noem het calendar

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final secure = SecureStorageService();
  final timerProvider = TimerProvider();
  String? locationEnabled = await secure.readData('location_enabled');

  if (locationEnabled != 'true') {
    await Geolocator.requestPermission();
  }
  await timerProvider.checkActiveClocking();


  runApp(ChangeNotifierProvider(
    create: (context) => TimerProvider(),
    child: MyApp(),
  ));
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
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) {
        return CalendarScreen();
      },
    ),
    GoRoute(
      path: '/clock-in',
      builder: (context, state) => const ClockInScreen(),
    ),
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
  final timerProvider = Provider.of<TimerProvider>(context);
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
        _buildClockInMenuItem(
          context, 
          timerProvider, 
          currentRoute
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

Future<bool> checkActiveClocking() async {
  final ApiService apiService = ApiService();
  final secure = SecureStorageService();
  final bool isClocking;

  try {
    final response = await apiService.getTempWork();

    if (response != null && response.clientId.isNotEmpty){
      isClocking = true;
      secure.writeData('activeClocking', 'true');
      return isClocking;
    } else {
      isClocking = false;
      secure.writeData('activeClocking', 'false');
      return isClocking;
    }
  } catch (e) {

    throw Exception(e);
  }
}

Future<void> navigateToRegistrationOverview(BuildContext context) async {
  
    final registrationData = await getFormattedTempWork();
    print('Before registration data');
    print(registrationData);

    context.go(
      '/registration-overview', 
      extra: registrationData
    );
    
}

Future<Map<String, dynamic>> getFormattedTempWork() async {
  final secure = SecureStorageService();
  final apiService = ApiService();

  final tempWorkResponse = await apiService.getTempWork();
  if (tempWorkResponse!.clientId.isEmpty) return {};

  List<ClientResponse> clients = await apiService.getClients();

  ClientResponse? matchedClient = clients.firstWhere(
    (client) => client.id == tempWorkResponse.clientId
  );

  ProjectModel? matchedProject = matchedClient.projects.firstWhere(
    (project) => project.id == tempWorkResponse.projectId
  );

  String startDateTime = tempWorkResponse.startTime.utcTime;
  DateTime parsedStartDate = DateTime.parse(startDateTime);
  String formattedStartTime = DateFormat('hh:mm a').format(parsedStartDate);
  // String? endDateTime = DateTime.now().toString();
  

  return {
    'startTime' : formattedStartTime,
    'startDate' : DateFormat('dd/MM/yyyy').format(parsedStartDate),
    'endTime' : tempWorkResponse.endTime != null
              ? DateFormat('hh:mm a').format(DateTime.parse(tempWorkResponse.endTime!.utcTime))
              : '',
    'endDate' : DateFormat('dd/MM/yyyy').format(parsedStartDate),
    'clientName' : matchedClient.clientName,
    'projectName' : matchedProject.projectName,
    'date' : await secure.readData('currentDate') ?? '',
  };
}

// Future<Map<String, String>> getClockingData() async {
//   final secure = SecureStorageService();

//   return {
//     'startTime' : await secure.readData('currentStartTime') ?? '',
//     'startDate' : await secure.readData('currentStartDate') ?? '',
//     'endTime' : await secure.readData('currentEndTime') ?? '',
//     'endDate' : await secure.readData('currentEndDate') ?? '',
//     'clientName' : await secure.readData('currentClientName') ?? '',
//     'projectName' : await secure.readData('currentProjectName') ?? '',
//     'date' : await secure.readData('currentDate') ?? '',
//   };
// }

Widget _buildClockInMenuItem(BuildContext context, TimerProvider timerProvider, String currentRoute) {
  final bool isActive = currentRoute == '/clock-in';
  return ListTile(
    iconColor: isActive ? const Color(0xFFc1ffbf) : Colors.white,
    textColor: isActive ? const Color(0xFFc1ffbf) : Colors.white,
    leading: const Icon(Icons.access_time_outlined),
    title: timerProvider.isClocking
        ? Text(
          timerProvider.elapsedTime,
          style: const TextStyle(fontWeight: FontWeight.bold),
          )
        : Text(
          'Clock in',
          style: isActive ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
    onTap: () {
      if (timerProvider.isClocking) {
        navigateToRegistrationOverview(context);
      } else {
        context.go('/clock-in');
      }
    },
  );
}
