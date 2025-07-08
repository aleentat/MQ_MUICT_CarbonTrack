import 'package:flutter/material.dart';
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

    CarbonDiaryPage.logs.add(
      CarbonLogEntry(
        type: 'travel',
        description:
            '$_transportMode - $_distance km → ${_carbonOutput.toStringAsFixed(2)} kg CO₂',
        timestamp: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Entry added to diary')));

    setState(() {
      _calculated = false;
      _distance = 0;
      _carbonOutput = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF2),
      appBar: AppBar(
        title: Text('Travel Carbon Calculator'),
        backgroundColor: Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: _transportMode,
                isExpanded: true,
                underline: SizedBox(),
                items:
                    emissionFactors.keys.map((mode) {
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(mode),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _transportMode = value!),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Distance (km)'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: _distance == 0 ? '' : _distance.toString(),
              ),
              onChanged: (value) {
                setState(() {
                  _distance = double.tryParse(value) ?? 0;
                  _calculated = false;
                });
              },
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateCarbon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4C6A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Calculate', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Carbon Output: ${_carbonOutput.toStringAsFixed(2)} kg CO₂',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculated ? _addToDiary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _calculated ? Color(0xFF4C6A4F) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Add to Diary',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
