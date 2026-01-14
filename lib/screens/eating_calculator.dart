import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EatingCalculator extends StatefulWidget {
  @override
  _EatingCalculatorState createState() =>
      _EatingCalculatorState();
}

class _EatingCalculatorState extends State<EatingCalculator> {
  final Map<String, double> menuCarbon = {
    'Beef Burger': 5.2,
    'Pork Rice': 3.5,
    'Chicken Rice': 2.1,
    'Pad Thai': 2.8,
    'Fried Rice': 2.5,
    'Vegetable Stir-fry': 0.9,
    'Salad': 0.6,
    'Pizza': 4.0,
  };

  final Set<String> selectedMenus = {};
  double totalCarbon = 0.0;
  bool calculated = false;

  void _calculateCarbon() {
    double sum = 0.0;
    for (var item in selectedMenus) {
      sum += menuCarbon[item] ?? 0;
    }

    setState(() {
      totalCarbon = sum;
      calculated = true;
    });
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
            'Eating Calculator',
            style: GoogleFonts.poppins(
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
              _buildMenuGrid(),
              const SizedBox(height: 30),
              _buildCalculateButton(),
              if (calculated) ...[
                const SizedBox(height: 30),
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset('assets/gif/eat.gif', height: 90),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Choose what you ate today 🍽\nWe’ll calculate the footprint',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Menu Grid
  Widget _buildMenuGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Select your menu'),
        const SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children:
              menuCarbon.keys.map((menu) {
                final bool selected = selectedMenus.contains(menu);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selected
                          ? selectedMenus.remove(menu)
                          : selectedMenus.add(menu);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? const Color.fromARGB(255, 76, 175, 134)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            selected
                                ? const Color.fromARGB(255, 76, 175, 134)
                                : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color:
                                selected ? Colors.white : Colors.green[700],
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            menu,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  selected
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${menuCarbon[menu]} kg CO₂',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  selected
                                      ? Colors.white70
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // Button
  Widget _buildCalculateButton() {
    return Center(
      child: ElevatedButton(
        onPressed:
            selectedMenus.isEmpty ? null : _calculateCarbon,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 29, 71, 62),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Calculate Carbon',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Result
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
              'Your Meal Carbon Footprint',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...selectedMenus.map((m) => Text('🍽 $m')),
            const SizedBox(height: 12),
            Text(
              '${totalCarbon.toStringAsFixed(2)} kg CO₂',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 226, 83, 73),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
}
