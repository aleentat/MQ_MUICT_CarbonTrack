import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/eating_diary_entry.dart';
import '../services/statistic_service.dart';

class EatingCalculator extends StatefulWidget {
  @override
  State<EatingCalculator> createState() => _EatingCalculatorState();
}

class _EatingCalculatorState extends State<EatingCalculator> {
  final List<Map<String, String>> foods = [
    {'name': 'Burger', 'image': 'assets/images/foods/burger.png'},
    {'name': 'Salad', 'image': 'assets/images/foods/salad.png'},
    {'name': 'Pad Krapow', 'image': 'assets/images/foods/pad_krapow.png'},
    {'name': 'Spaghetti', 'image': 'assets/images/foods/spaghetti.png'},
    {'name': 'Steak', 'image': 'assets/images/foods/steak.png'},
    {'name': 'Fried Rice', 'image': 'assets/images/foods/fried_rice.png'},
  ];

  final List<Map<String, String>> meats = [
    {'name': 'Beef', 'image': 'assets/images/foods/meat.png'},
    {'name': 'Chicken', 'image': 'assets/images/foods/chicken.png'},
    {'name': 'Pork', 'image': 'assets/images/foods/pork.png'},
    {'name': 'Fish', 'image': 'assets/images/foods/fish.png'},
  ];

  final PageController _meatController = PageController(viewportFraction: 0.6);

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
    await StatisticService.sendTodaySummary();

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
              // ✅ HEADER (THIS WAS MISSING BEFORE)
              _buildHeaderCard(),
              const SizedBox(height: 25),

              _sectionTitle('Select food'),
              _foodGrid(),

              if (selectedFood != null && selectedFood != 'Salad') ...[
                const SizedBox(height: 25),
                _sectionTitle('Select meat'),
                _meatSlider(),
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
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        final isSelected = selectedFood == food['name'];

        return GestureDetector(
          onTap: () => _selectFood(food['name']!),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color.fromARGB(255, 76, 175, 134)
                      : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(food['image']!, width: 70, fit: BoxFit.contain),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color.fromARGB(255, 64, 160, 120)
                            : Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    food['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _meatSlider() {
    return SizedBox(
      height: 190,
      child: Stack(
        children: [
          PageView.builder(
            controller: _meatController,
            itemCount: meats.length,
            onPageChanged: (index) {
              _selectMeat(meats[index]['name']!);
            },
            itemBuilder: (context, index) {
              final meat = meats[index];
              final isSelected = selectedMeat == meat['name'];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromARGB(255, 76, 175, 134)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(meat['image']!, height: 80),
                    const SizedBox(height: 10),
                    Text(
                      meat['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ⬅ Arrow Left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                _meatController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),

          // ➡ Arrow Right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _meatController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
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
              style: TextStyle(
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
          style: TextStyle(
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
        style: TextStyle(
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