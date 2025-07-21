import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Reset db
  // final dbPath = await getDatabasesPath();
  // await deleteDatabase(join(dbPath, 'waste_items.db'));
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