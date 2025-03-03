import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_poc_reloaded/screens/user_selection_screen.dart';
import 'package:flutter_poc_reloaded/screens/EditClockInScreen.dart';
import 'package:flutter_poc_reloaded/screens/event_details_screen.dart';
import 'package:go_router/go_router.dart';
import '/screens/calendar_screen.dart';
import '/screens/clock_in_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background notification service
void startBackgroundService() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? isClockedIn = prefs.getBool('isClockedIn');

  WidgetsFlutterBinding.ensureInitialized();
  
  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher'
  );
  if (isClockedIn == true) {
    // Als de app wordt opgestart en we waren ingeklokt, start de notificatie updates
    ClockInScreen.instance?.startNotificationUpdates();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      print("Received iOS Notification: $title, $body");
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: iosSettings);

  // Configureer de notification action
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      print(
          'Received notification response: ${notificationResponse.actionId}, ${notificationResponse.payload}');

      if (notificationResponse.actionId == 'CLOCK_OUT' ||
          notificationResponse.payload == 'CLOCK_OUT') {
        // Uitklok actie
        print('Clock out via notification');
        if (ClockInScreen.instance != null) {
          await ClockInScreen.instance!.handleClockOut();
        }
      } else {
        // Normale tap op notificatie
        _router.go('/clock-in');
      }
    },
  );

  // Start de background service
  startBackgroundService();

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id',
    'your_channel_name',
    description: 'your_channel_description',
    importance: Importance.max,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  _requestiOSPermissons();

  runApp(MyApp());
}

void _requestiOSPermissons() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
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
      path: '/edit-clock-in',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return EditClockInScreen(
          date: extra['date'] as DateTime,
          currentClockIn: extra['clockInTime'] as String,
          currentClockOut: extra['clockOutTime'] as String,
          currentNotes: extra['notes'] as String,
        );
      },
    ),
    GoRoute(
      path: '/event-details',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return EventDetailsScreen(
          formattedDate: extra['formattedDate'] as String,
          clockInTime: extra['clockInTime'] as String,
          clockOutTime: extra['clockOutTime'] as String,
          noteText: extra['notes'] as String,
          location: extra['location'] as String,
          onEditPressed: extra['onEditPressed'] as Function,
        );
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
        // final Map<String, dynamic>? userProfile = state.extra as Map<String, dynamic>?;
        return ProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/profile_testing',
      builder: (context, state) {
        return UserSelectionScreen();
      },
    ),
  ],
);