import 'package:flutter/material.dart';
import 'carbon_log_entry.dart';
import 'carbon_diary_page.dart';

class TravelCarbonCalculator extends StatefulWidget {
  @override
  _TravelCarbonCalculatorState createState() => _TravelCarbonCalculatorState();
}

class _TravelCarbonCalculatorState extends State<TravelCarbonCalculator> {
  String _transportMode = 'Car';
  double _distance = 0;
  double _carbonOutput = 0;
  bool _calculated = false;

  final Map<String, double> emissionFactors = {
    'Car': 0.21,
    'Bus': 0.1,
    'Train': 0.05,
    'Bike': 0.0,
    'Walk': 0.0,
  };

  void _calculateCarbon() {
    double factor = emissionFactors[_transportMode] ?? 0;
    double result = _distance * factor;
    setState(() {
      _carbonOutput = result;
      _calculated = true;
    });
  }

  void _addToDiary() {
    if (!_calculated) return;

    CarbonDiaryPage.logs.add(CarbonLogEntry(
      type: 'travel',
      description: '$_transportMode - $_distance km → ${_carbonOutput.toStringAsFixed(2)} kg CO₂',
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry added to diary')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travel Carbon Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _transportMode,
              items: emissionFactors.keys.map((mode) {
                return DropdownMenuItem<String>(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (value) => setState(() => _transportMode = value!),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Distance (km)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _distance = double.tryParse(value) ?? 0;
                  _calculated = false; // reset state when distance changes
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateCarbon,
              child: Text('Calculate'),
            ),
            SizedBox(height: 10),
            Text(
              'Carbon Output: ${_carbonOutput.toStringAsFixed(2)} kg CO₂',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculated ? _addToDiary : null,
              child: Text('Add to Diary'),
            ),
          ],
        ),
      ),
    );
  }
}
