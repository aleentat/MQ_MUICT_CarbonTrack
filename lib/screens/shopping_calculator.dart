import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShoppingCalculator extends StatefulWidget {
  @override
  _ShoppingCalculatorState createState() =>
      _ShoppingCalculatorState();
}

class _ShoppingCalculatorState extends State<ShoppingCalculator> {
  String _category = 'Clothing';
  int _quantity = 1;

  double _carbonResult = 0.0;
  bool _calculated = false;

  final Map<String, double> shoppingEF = {
    'Clothing': 6.0,
    'Electronics': 50.0,
    'Household': 3.0,
    'Furniture': 40.0,
    'Personal Care': 2.0,
  };

  final List<String> categories = [
    'Clothing',
    'Electronics',
    'Household',
    'Furniture',
    'Personal Care',
  ];

  void _calculateCarbon() {
    double baseEF = shoppingEF[_category] ?? 0;

    setState(() {
      _carbonResult = baseEF * _quantity;
      _calculated = true;
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
            'Shopping Calculator',
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
              _buildCategorySelector(),
              const SizedBox(height: 25),
              _buildQuantitySelector(),
              const SizedBox(height: 30),
              _buildCalculateButton(),
              if (_calculated) ...[
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
          Image.asset('assets/gif/shop.gif', height: 90),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Every purchase leaves a footprint.\nLet’s track it 🌱',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Category
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('What did you buy?'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((c) {
            final selected = _category == c;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                width: (MediaQuery.of(context).size.width - 60) / 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                ),
                child: Center(
                  child: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Quantity
  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Quantity'),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed:
                    _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
              ),
              Text(
                _quantity.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Button
  Widget _buildCalculateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _calculateCarbon,
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Result',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('🛍 Category: $_category'),
            Text('🔢 Quantity: $_quantity'),
            const SizedBox(height: 10),
            Text(
              '${_carbonResult.toStringAsFixed(2)} kg CO₂',
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