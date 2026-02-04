import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Reset db
  // final dbPath = await getDatabasesPath();
  // await deleteDatabase(join(dbPath, 'waste_items.db'));
  
  runApp(CarbonDiaryApp());
  
  await DBHelper.instance.incrementAppOpen();
}

class CarbonDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(useMaterial3: true,),
      // theme: ThemeData(textTheme: GoogleFonts.nunitoTextTheme()),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}