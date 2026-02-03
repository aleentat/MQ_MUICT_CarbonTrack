import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../models/eating_diary_entry.dart';

class EatingCalculator extends StatefulWidget {
  @override
  State<EatingCalculator> createState() => _EatingCalculatorState();
}

class _EatingCalculatorState extends State<EatingCalculator> {
  final List<String> foods = ['Burger', 'Salad','Pad Krapow', 'Spaghetti','Steak', 'Fried Rice'];
  final List<String> meats = ['Beef', 'Chicken', 'Pork', 'Fish'];

  String? selectedFood;
  String? selectedMeat;
  double? carbon;

  // ---------------- Fetch carbon from DB ----------------
  Future<void> _selectMeat(String meat) async {
    final value = await DBHelper.instance.getFoodCarbon(
      selectedFood!,
      selectedFood == 'Salad' ? null : meat,
    );

  debugPrint(
    '[EatingCalculator] Food: $selectedFood | Meat: ${meat.isEmpty ? 'None' : meat} | Carbon: $value kg CO₂e',
  );

    setState(() {
      selectedMeat = meat;
      carbon = value;
    });
  }

  // ---------------- Save diary ----------------
  Future<void> _saveDiary() async {
    if (selectedFood == null || carbon == null) return;

    await DBHelper.instance.insertEatingDiaryEntry(
      EatingDiaryEntry(
        name: selectedFood!,
        variant: selectedMeat,
        carbon: carbon!,
        timestamp: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to eating diary 🌱')),
    );

    setState(() {
      selectedFood = null;
      selectedMeat = null;
      carbon = null;
    });
  }

  // ---------------- UI ----------------
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
              // ✅ HEADER (THIS WAS MISSING BEFORE)
              _buildHeaderCard(),
              const SizedBox(height: 25),

              _sectionTitle('Select food'),
              _grid(foods, selectedFood, _selectFood),

              if (selectedFood != null && selectedFood != 'Salad') ...[
                const SizedBox(height: 25),
                _sectionTitle('Select meat'),
                _grid(meats, selectedMeat, _selectMeat),
              ],

              if (carbon != null) ...[
                const SizedBox(height: 30),
                _buildResultCard(),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset(
            'assets/gif/eat.gif',
            height: 90,
            fit: BoxFit.contain,
          ),
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

  Widget _grid(
    List<String> items,
    String? selected,
    Function(String) onTap,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map((item) {
        final isSelected = item == selected;

        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color.fromARGB(255, 76, 175, 134)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? const Color.fromARGB(255, 76, 175, 134)
                        : Colors.grey.shade300,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text('🍽 $selectedFood'),
            if (selectedMeat != null) Text('🥩 $selectedMeat'),
            const SizedBox(height: 12),
            Text(
              '${carbon!.toStringAsFixed(2)} kg CO₂e',
              style: GoogleFonts.poppins(
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

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 29, 71, 62),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Save to Diary',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  void _selectFood(String food) {
    setState(() {
      selectedFood = food;
      selectedMeat = null;
      carbon = null;
    });

    if (food == 'Salad') {
      _selectMeat('');
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}