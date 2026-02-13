import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/shopping_diary_entry.dart';
import '../services/statistic_service.dart';

class ShoppingCalculator extends StatefulWidget {
  @override
  _ShoppingCalculatorState createState() => _ShoppingCalculatorState();
}

class _ShoppingCalculatorState extends State<ShoppingCalculator> {
  String _category = 'Clothing';
  int _quantity = 1;

  List<Map<String, dynamic>> _products = [];
  int? _selectedProductId;

  double _carbonResult = 0.0;
  bool _calculated = false;

  final List<String> categories = [
    'Clothing',
    'Electronics',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DBHelper.instance.getShoppingItems(_category);
    setState(() {
      _products = data;
      _selectedProductId = null;
      _calculated = false;
    });
  }

  void _calculateCarbon() {
    if (_selectedProductId == null) return;

    final selectedProduct = _products.firstWhere(
      (product) => product['id'] == _selectedProductId,
    );
    double ef = (selectedProduct['emission_factor'] as num).toDouble();

    setState(() {
      _carbonResult = ef * _quantity;
      _calculated = true;
    });
  }

  Future<void> _saveToDiary() async {
    if (_selectedProductId == null) return;

    final selectedProduct = _products.firstWhere(
      (product) => product['id'] == _selectedProductId,
    );

    final entry = ShoppingDiaryEntry(
      name: selectedProduct['name'],
      category: _category,
      timestamp: DateTime.now(),
      quantity: _quantity,
      note: '',
      unit:
          (selectedProduct['emission_factor'] as num).toDouble(),
      carbon: _carbonResult,
    );

    await DBHelper.instance.insertShoppingLog(entry);
    await StatisticService.sendTodaySummary();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved to Carbon Diary 🌱")),
    );

    setState(() {
      _calculated = false;
      _quantity = 1;
      _selectedProductId = null;
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
          title: const Text(
            'Shopping Calculator',
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
              _buildCategorySelector(),
              const SizedBox(height: 25),
              _buildProductSelector(),
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset('assets/gif/shop.gif', height: 90),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              'Every purchase leaves a footprint.\nLet’s track it 🌱',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

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
              onTap: () {
                setState(() => _category = c);
                _loadProducts();
              },
              child: Container(
                width:
                    (MediaQuery.of(context).size.width - 60) / 2,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color.fromARGB(
                          255, 76, 175, 134)
                      : Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color.fromARGB(
                            255, 76, 175, 134)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : Colors.black87,
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

  Widget _buildProductSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Select Product'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _cardDecoration(),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedProductId,
            hint: const Text("Choose item"),
            isExpanded: true,
            items: _products.map<DropdownMenuItem<int>>((product) {
              return DropdownMenuItem<int>(
                value: product['id'],
                child: Text(product['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
              });
            },
          ),
        ),
      ),
    ],
  );
}

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Quantity'),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.remove_circle_outline),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Text(
                _quantity.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.add_circle_outline),
                onPressed: () =>
                    setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _calculateCarbon,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 29, 71, 62),
          padding: const EdgeInsets.symmetric(
              horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30),
          ),
        ),
        child: const Text(
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculation Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
                '🛍 Product: ${_selectedProductId == null ? '' : _products.firstWhere((p) => p['id'] == _selectedProductId)['name']}'),
            Text('🔢 Quantity: $_quantity'),
            const SizedBox(height: 10),
            Text(
              '${_carbonResult.toStringAsFixed(2)} kg CO₂',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color:
                    Color.fromARGB(255, 226, 83, 73),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _saveToDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(
                        255, 29, 71, 62),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Save to Diary',
                style:
                    TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3)),
      ],
    );
  }
}
