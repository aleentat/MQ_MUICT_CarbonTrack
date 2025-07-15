import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await resetDB();
  runApp(CarbonDiaryApp());
}

class CarbonDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFE8ECD7)),
      home: HomePage(),
    );
  }
}

Future<void> resetDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'waste_items.db');
  await deleteDatabase(path);
  print("✅ Database reset complete");
}
