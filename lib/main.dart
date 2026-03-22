import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page.dart';
import 'database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.init();
  runApp(CarbonDiaryApp());
  _initAsync();
}

Future<void> _initAsync() async {
  final prefs = await SharedPreferences.getInstance();
  bool isOn = prefs.getBool('daily_notification') ?? false;

  if (isOn) {
    await NotificationService.scheduleDaily8AM();
  }

  await DBHelper.instance.incrementAppOpen();
}

class CarbonDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(useMaterial3: true,),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}