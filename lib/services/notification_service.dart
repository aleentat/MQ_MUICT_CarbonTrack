import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleDaily8AM() async {
    await _notifications.zonedSchedule(
        0,
        'Carbon Diary 🌱',
        'Start your day by logging your activities!',
        _nextInstanceOf8AM(),
        const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Reminder',
            importance: Importance.max,
            priority: Priority.high,
        ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,

        matchDateTimeComponents: DateTimeComponents.time,
    );
}

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOf8AM() {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}