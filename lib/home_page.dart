import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'travel_carbon_calculator.dart';
import 'waste_sorting_guide.dart';
import 'carbon_diary_page.dart';

class HomePage extends StatelessWidget {
  final String today = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carbon Diary')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today: $today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TravelCarbonCalculator()),
              ),
              child: Text('Travel Carbon Calculator'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WasteSortingGuide()),
              ),
              child: Text('Waste Sorting Guide'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarbonDiaryPage()),
              ),
              child: Text('View Carbon Diary'),
            ),
          ],
        ),
      ),
    );
  }
}