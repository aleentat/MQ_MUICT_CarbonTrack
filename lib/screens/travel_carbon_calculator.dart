import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import '../models/travel_diary_entry.dart';

class TravelCarbonCalculator extends StatefulWidget {
  @override
  _TravelCarbonCalculatorState createState() => _TravelCarbonCalculatorState();
}

class _TravelCarbonCalculatorState extends State<TravelCarbonCalculator> {
  final _startController = TextEditingController();
  final _destController = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> startPredictions = [];
  List<AutocompletePrediction> destPredictions = [];

  String _transportMode = 'Diesel Car';
  double _distance = 0;
  double _carbonOutput = 0;
  bool _calculated = false;

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

 @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ Missing or invalid GOOGLE_API_KEY in .env');
    } else {
      googlePlace = GooglePlace(apiKey);
    }
  }

  void _calculateCarbon() {
    double factor = emissionFactors[_transportMode] ?? 0;
    double result = _distance * factor;
    setState(() {
      _carbonOutput = result;
      _calculated = true;
    });
  }

  Future<void> _addToDiary() async {
    if (!_calculated) return;
    final entry = TravelDiaryEntry(
      mode: _transportMode,
      distance: _distance,
      carbon: _carbonOutput,
      timestamp: DateTime.now(), 
      startLocation: _startController.text,
      endLocation: _destController.text,
    );
    await DBHelper.instance.insertTravelDiaryEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to diary: ${_carbonOutput.toStringAsFixed(2)} kg CO₂')),
    );
    setState(() {
      _calculated = false;
      _distance = 0;
      _carbonOutput = 0;
      _startController.clear();
      _destController.clear();
    });
  }

  void _onStartChanged(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        startPredictions = result.predictions!;
      });
    }
  }

  void _onDestChanged(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        destPredictions = result.predictions!;
      });
    }
  }

  Future<void> _calculateDistance() async {
    final origin = _startController.text;
    final destination = _destController.text;
    final apiKey = dotenv.env['GOOGLE_API_KEY'];

    final url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['rows'][0]['elements'][0]['status'] == 'OK') {
        final meters = data['rows'][0]['elements'][0]['distance']['value'];
        final km = meters / 1000;
        setState(() {
          _distance = km;
        });
        _calculateCarbon();
      } else {
        _showError("Could not calculate distance.");
      }
    } else {
      _showError("Failed to fetch distance.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Start Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _startController,
                onChanged: _onStartChanged,
                decoration: InputDecoration(hintText: 'Enter start point'),
              ),
              ...startPredictions.map(
                (p) => ListTile(
                  title: Text(p.description ?? ''),
                  onTap: () {
                    _startController.text = p.description!;
                    setState(() => startPredictions = []);
                  },
                ),
              ),
              SizedBox(height: 10),
              Text('Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _destController,
                onChanged: _onDestChanged,
                decoration: InputDecoration(hintText: 'Enter destination'),
              ),
              ...destPredictions.map(
                (p) => ListTile(
                  title: Text(p.description ?? ''),
                  onTap: () {
                    _destController.text = p.description!;
                    setState(() => destPredictions = []);
                  },
                ),
              ),
              SizedBox(height: 20),
              Text('Transport Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              ElevatedButton(
                onPressed: _calculateDistance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4C6A4F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Calculate Carbon Footprint', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              if (_calculated)
                Card(
                  color: Color(0xFFE6F0E9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calculation Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4C6A4F))),
                        SizedBox(height: 10),
                        Text('Distance traveled: ${_distance.toStringAsFixed(2)} km', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 6),
                        Text('Transport mode: $_transportMode', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 6),
                        Text('Estimated carbon output:', style: TextStyle(fontSize: 16)),
                        Text('${_carbonOutput.toStringAsFixed(2)} kg CO₂', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[700])),
                        SizedBox(height: 12),
                        Text('This estimate is based on average emission factors per kilometer for the selected transport mode.', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculated ? _addToDiary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calculated ? Color(0xFF4C6A4F) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Add to Diary', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}