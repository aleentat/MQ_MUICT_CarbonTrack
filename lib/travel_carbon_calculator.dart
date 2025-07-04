import 'package:flutter/material.dart';

class TravelCarbonCalculator extends StatefulWidget {
  @override
  _TravelCarbonCalculatorState createState() => _TravelCarbonCalculatorState();
}

class _TravelCarbonCalculatorState extends State<TravelCarbonCalculator> {
  String _transportMode = 'Car';
  double _distance = 0;
  double _carbonOutput = 0;

  final Map<String, double> emissionFactors = {
    'Car': 0.21,
    'Bus': 0.1,
    'Train': 0.05,
    'Bike': 0.0,
    'Walk': 0.0,
  };

  void _calculateCarbon() {
    double factor = emissionFactors[_transportMode] ?? 0;
    setState(() {
      _carbonOutput = _distance * factor;
    });
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
              items: emissionFactors.keys.map((String mode) {
                return DropdownMenuItem<String>(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _transportMode = value!;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Distance (km)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _distance = double.tryParse(value) ?? 0;
              },
            ),
            ElevatedButton(
              onPressed: _calculateCarbon,
              child: Text('Calculate'),
            ),
            SizedBox(height: 20),
            Text('Carbon Output: ${_carbonOutput.toStringAsFixed(2)} kg CO₂'),
          ],
        ),
      ),
    );
  }
}
