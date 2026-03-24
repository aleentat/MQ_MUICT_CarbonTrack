import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page.dart';
import 'database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'services/smart_travel_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("dotenv failed: $e");
  }

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("notification init failed: $e");
  }

  try {
    await _initAsync();
  } catch (e) {
    debugPrint("async init failed: $e");
  }

  try {
    await DBHelper.instance.incrementAppOpen();
  } catch (e) {
    debugPrint("DB init failed: $e");
  }

  try {
    await SmartTravelService().init();
  } catch (e) {
    debugPrint("SmartTravelService init failed: $e");
  }

  runApp(CarbonDiaryApp());
}

Future<void> _initAsync() async {
  final prefs = await SharedPreferences.getInstance();
  bool isOn = prefs.getBool('daily_notification') ?? false;

  if (isOn) {
    await NotificationService.scheduleDaily8AM();
  }
}

class CarbonDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}