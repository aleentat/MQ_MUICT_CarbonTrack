import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
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
  String _vehicleType = 'Diesel Car';
  String _subType = 'Small';

  final Map<String, Map<String, double>> vehicleOptions = {
    'Diesel Car': {'Small': 0.139306448880537, 'Medium': 0.167156448880537, 'Large': 0.208586448880537, 'Mini': 0.107746448880537, 'Supermini': 0.132146448880537, 'Luxury': 0.211196448880537, 'Sports': 0.169436448880537},
    'Petrol Car': {'Small': 0.140798534228188, 'Medium': 0.178188534228188, 'Large': 0.272238534228188, 'Mini': 0.130298534228188, 'Supermini': 0.141688534228188, 'Luxury': 0.318088534228188, 'Sports': 0.237158534228188},
    'Hybrid Car': {'Small': 0.101498857718121, 'Medium': 0.109038436241611, 'Large': 0.1524358},
    'Battery Electric Car': {'Small': 0.0482282859060403, 'Medium': 0.0526663489932886, 'Large': 0.05737, 'Mini': 0.0443381932885906, 'Supermini': 0.0490671785234899, 'Luxury': 0.0583732120805369, 'Sports': 0.0834804456375839},
    'Bus': {'Regular': 0.102150394630872, 'Coach': 0.0271814013422819, 'Trolleybus': 0.00699},
    'Train': {'National rail': 0.0354629637583893, 'Light rail and tram': 0.028603267114094, 'Underground': 0.027802067114094},
    'Motorcycle': {'Small': 0.0831851865771812, 'Medium': 0.10107835704698, 'Large': 0.13251915704698},
    'Bicycle': {'None': 0.0},
    'Walk': {'None': 0.0},
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
    double factor = vehicleOptions[_vehicleType]?[_subType] ?? 0;
    double result = _distance * factor;
    setState(() {
      _carbonOutput = result;
      _calculated = true;
    });
  }

  Future<void> _addToDiary() async {
    if (!_calculated) return;
    final entry = TravelDiaryEntry(
      mode: '$_vehicleType ($_subType)',
      distance: _distance,
      carbon: _carbonOutput,
      timestamp: DateTime.now(),
      startLocation: _startController.text,
      endLocation: _destController.text,
    );
    await DBHelper.instance.insertTravelDiaryEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added to diary: ${_carbonOutput.toStringAsFixed(2)} kg CO₂',
        ),
      ),
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

  TextStyle headingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF4C6A4F),
  );
  TextStyle labelStyle = TextStyle(fontSize: 15, color: Colors.black87);

  Widget _buildLocationField(
    TextEditingController controller,
    Function(String) onChanged,
    List<AutocompletePrediction> predictions,
  ) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter location',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        ...predictions.map(
          (p) => ListTile(
            title: Text(p.description ?? ''),
            onTap: () {
              controller.text = p.description!;
              setState(() => predictions.clear());
            },
          ),
        ),
      ],
    );
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        height: 30,
                        width: 30,
                      ),
                      Container(
                        height: 65,
                        child: DottedLine(
                          direction: Axis.vertical,
                          dashLength: 6,
                          dashGapLength: 4,
                          lineThickness: 2,
                          dashColor: Colors.grey,
                        ),
                      ),
                      Image.asset(
                        'assets/images/location.png',
                        height: 30,
                        width: 30,
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Location', style: headingStyle),
                        _buildLocationField(
                          _startController,
                          _onStartChanged,
                          startPredictions,
                        ),
                        SizedBox(height: 25),
                        Text('Destination', style: headingStyle),
                        _buildLocationField(
                          _destController,
                          _onDestChanged,
                          destPredictions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Image.asset(
                    'assets/images/transport.png',
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(width: 8),
                  Text('Transport Mode', style: headingStyle),
                ],
              ),
              SizedBox(height: 20),
              // Vehicle Type Dropdown
              Text('Vehicle Type', style: headingStyle),
              Container(
                margin: EdgeInsets.only(top: 6),
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _vehicleType,
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      vehicleOptions.keys.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type, style: labelStyle),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _vehicleType = value!;
                      _subType = vehicleOptions[_vehicleType]!.keys.first;
                    });
                  },
                ),
              ),

              SizedBox(height: 16),

              // Subtype Dropdown
              Text('Vehicle Detail', style: headingStyle),
              Container(
                margin: EdgeInsets.only(top: 6),
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _subType,
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      vehicleOptions[_vehicleType]!.keys.map((subtype) {
                        return DropdownMenuItem<String>(
                          value: subtype,
                          child: Text(subtype, style: labelStyle),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => _subType = value!);
                  },
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _calculateDistance,
                  icon: Icon(Icons.calculate),
                  label: Text('Calculate Carbon Footprint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4C6A4F),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (_calculated) ...[
                SizedBox(height: 30),
                Card(
                  color: Color(0xFFE6F0E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 Calculation Result',
                          style: headingStyle.copyWith(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '🛣️ Distance: ${_distance.toStringAsFixed(2)} km',
                          style: labelStyle,
                        ),
                        Text('🚗 Mode: $_transportMode', style: labelStyle),
                        SizedBox(height: 6),
                        Text('🌍 Carbon Emission:', style: labelStyle),
                        Text(
                          '${_carbonOutput.toStringAsFixed(2)} kg CO₂',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Estimated based on average emission factors per km.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _calculated ? _addToDiary : null,
                  icon: Icon(Icons.save),
                  label: Text('Add to Diary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _calculated ? Color(0xFF4C6A4F) : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
