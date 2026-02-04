import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import '../models/travel_diary_entry.dart';
import '../services/statistic_service.dart';

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

  double _distance = 0;
  double _carbonOutput = 0;
  bool _calculated = false;
  String _vehicleType = 'Diesel Car';
  String _subType = 'Small';

  final Map<String, Map<String, double>> vehicleOptions = {
    'Diesel Car': {
      'Small': 0.139306448880537,
      'Medium': 0.167156448880537,
      'Large': 0.208586448880537,
      'Mini': 0.107746448880537,
      'Supermini': 0.132146448880537,
      'Luxury': 0.211196448880537,
      'Sports': 0.169436448880537,
    },
    'Petrol Car': {
      'Small': 0.140798534228188,
      'Medium': 0.178188534228188,
      'Large': 0.272238534228188,
      'Mini': 0.130298534228188,
      'Supermini': 0.141688534228188,
      'Luxury': 0.318088534228188,
      'Sports': 0.237158534228188,
    },
    'Hybrid Car': {
      'Small': 0.101498857718121,
      'Medium': 0.109038436241611,
      'Large': 0.1524358,
    },
    'Electric Car': {
      'Small': 0.0482282859060403,
      'Medium': 0.0526663489932886,
      'Large': 0.05737,
      'Mini': 0.0443381932885906,
      'Supermini': 0.0490671785234899,
      'Luxury': 0.0583732120805369,
      'Sports': 0.0834804456375839,
    },
    'Bus': {
      'Regular': 0.102150394630872,
      'Coach': 0.0271814013422819,
      'Trolleybus': 0.00699,
    },
    'Train': {
      'National rail': 0.0354629637583893,
      'Light rail and tram': 0.028603267114094,
      'Underground': 0.027802067114094,
    },
    'Motorcycle': {
      'Small': 0.0831851865771812,
      'Medium': 0.10107835704698,
      'Large': 0.13251915704698,
    },
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
    await StatisticService.sendTodaySummary();
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
    color: Color.fromARGB(255, 40, 69, 45),
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

  Widget _buildVehicleTypeSelector() {
    final types = vehicleOptions.keys.toList();

    final iconsMap = {
      'Diesel Car': Icons.local_gas_station,
      'Petrol Car': Icons.local_gas_station,
      'Hybrid Car': Icons.electric_car,
      'Electric Car': Icons.ev_station,
      'Bus': Icons.directions_bus,
      'Train': Icons.train,
      'Motorcycle': Icons.motorcycle,
      'Bicycle': Icons.pedal_bike,
      'Walk': Icons.directions_walk,
    };

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children:
          types.map((type) {
            final isSelected = _vehicleType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _vehicleType = type;
                  _subType = vehicleOptions[_vehicleType]!.keys.first;
                });
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 90) / 3,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF44765F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? Color(0xFF44765F) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconsMap[type] ?? Icons.directions_car,
                      color: isSelected ? Colors.white : Color(0xFF44765F),
                      size: 26,
                    ),
                    SizedBox(height: 6),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF44765F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset('assets/gif/travel.gif', height: 90),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Track your travel footprint 🚗\nEvery trip counts',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From & To', style: headingStyle),
          const SizedBox(height: 15),
          _buildLocationField(
            _startController,
            _onStartChanged,
            startPredictions,
          ),
          const SizedBox(height: 20),
          _buildLocationField(_destController, _onDestChanged, destPredictions),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Type', style: headingStyle),
          const SizedBox(height: 15),
          _buildVehicleTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildSubtypeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Detail', style: headingStyle),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _subType,
            isExpanded: true,
            underline: SizedBox(),
            items:
                vehicleOptions[_vehicleType]!.keys.map((subtype) {
                  return DropdownMenuItem(value: subtype, child: Text(subtype));
                }).toList(),
            onChanged: (value) => setState(() => _subType = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _calculateDistance,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 29, 71, 62),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Calculate Carbon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('🛣 Distance: ${_distance.toStringAsFixed(2)} km'),
            Text('🚗 Mode: $_vehicleType ($_subType)'),
            const SizedBox(height: 10),
            Text(
              '${_carbonOutput.toStringAsFixed(2)} kg CO₂',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 226, 83, 73),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDiaryButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _addToDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 76, 175, 134),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Add to Diary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 155, 255, 242),
            Color.fromARGB(255, 183, 255, 236),
            Color.fromARGB(255, 230, 252, 252),
            Color(0xFFFDFDFD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          title: Text(
            'Travel Calculator',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 25),
              _buildLocationCard(),
              const SizedBox(height: 25),
              _buildVehicleCard(),
              const SizedBox(height: 25),
              _buildSubtypeCard(),
              const SizedBox(height: 30),
              _buildCalculateButton(),
              if (_calculated) ...[
                const SizedBox(height: 30),
                _buildResultCard(),
                const SizedBox(height: 20),
                _buildAddDiaryButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
