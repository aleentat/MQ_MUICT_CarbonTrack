import 'package:flutter/material.dart';
import 'home_page.dart';
//import 'carbon_log_entry.dart';

void main() => runApp(CarbonDiaryApp());

class CarbonDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}