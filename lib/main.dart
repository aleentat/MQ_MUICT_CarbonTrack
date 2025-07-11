import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() => runApp(CarbonDiaryApp());

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