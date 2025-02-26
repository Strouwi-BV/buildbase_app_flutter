import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/location_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  
  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher'
  );

  final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      print("Received iOs Notification: $title, $body");
    },
  );

  

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, 
    iOS: iosSettings
    
  );
  

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload == 'CLOCK_OUT') {
        print('Clock out via notification');
        // Handle clock out action here
      }
    },
  );

  

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id',
    'your_channel_name',
    description: 'your_channel_description',
    importance: Importance.max,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  _requestiOSPermissons();

  runApp(MyApp());
}

void _requestiOSPermissons() {
    flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation
      <IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
      );
  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
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
      path: '/location/:latitude/:longitude',
      builder: (context, state) {
        return LocationScreen();
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
