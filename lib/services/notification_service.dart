import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

static Future<void> init() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await _notifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {},
  );

  await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
}

static Future<void> scheduleDaily8AM() async {
  final tzTime = nextInstanceOf8AM();

  print("🔔 Scheduling notification at: $tzTime");
  
  final canExact = await _notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.canScheduleExactNotifications() ?? false;

  await _notifications.zonedSchedule(
    0,
    'Carbon Diary 🌱',
    'Start your day by logging your activities!',
    tzTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel',
        'Daily Reminder',
        channelDescription: 'Daily 8AM reminder',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    androidScheduleMode: canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle, 
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static tz.TZDateTime nextInstanceOf8AM() {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}