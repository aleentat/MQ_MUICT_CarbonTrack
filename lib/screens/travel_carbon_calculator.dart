import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class TravelCarbonCalculator extends StatefulWidget {
  @override
  _TravelCarbonCalculatorState createState() => _TravelCarbonCalculatorState();
}

class _TravelCarbonCalculatorState extends State<TravelCarbonCalculator> {
  String _transportMode = 'Diesel Car';
  double _distance = 0;
  double _carbonOutput = 0;
  bool _calculated = false;

  final List<String> _demoLog = []; // local demo logs

  final Map<String, double> emissionFactors = {
    'Diesel Car': 0.167156448880537,
    'Petrol Car': 0.178188534228188,
    'Electric Car': 0.0526663489932886,
    'Bus': 0.102150394630872,
    'Train': 0.0354629637583893,
    'Motorbike': 0.10107835704698,
    'Bicycle': 0.0,
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

    String log = '$_transportMode - $_distance km → ${_carbonOutput.toStringAsFixed(2)} kg CO₂';
    _demoLog.add(log);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demo: $log')),
    );

    setState(() {
      _calculated = false;
      _distance = 0;
      _carbonOutput = 0;
    });
  }

  final TextEditingController _distanceController = TextEditingController();

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _distanceController.text = _distance == 0 ? '' : _distance.toString();

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
                items: emissionFactors.keys.map((mode) {
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
              controller: _distanceController,
              decoration: InputDecoration(labelText: 'Distance (km)'),
              keyboardType: TextInputType.number,
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
                  'Add to Diary (Demo)',
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