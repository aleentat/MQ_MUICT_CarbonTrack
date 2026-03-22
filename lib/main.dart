import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(CarbonDiaryApp());
  
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