import 'package:flutter/material.dart';
import 'travel_carbon_calculator.dart';
import 'waste_sorting_guide.dart';

void main() {
  runApp(CarbonCalculatorApp());
}

class CarbonCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Diary',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carbon Diary')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TravelCarbonCalculator()));
              },
              child: Text('Travel Carbon Calculator'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WasteSortingGuide()));
              },
              child: Text('Waste Sorting Guide'),
            ),
          ],
        ),
      ),
    );
  }
}
