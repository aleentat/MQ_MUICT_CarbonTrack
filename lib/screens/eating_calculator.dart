import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/eating_diary_entry.dart';
import '../services/statistic_service.dart';

class EatingCalculator extends StatefulWidget {
  @override
  State<EatingCalculator> createState() => _EatingCalculatorState();
}

class _EatingCalculatorState extends State<EatingCalculator> {
  bool _showAllFoods = false;

  final List<Map<String, String>> foods = [
    {'name': 'Burger', 'image': 'assets/images/foods/burger.png'},
    {'name': 'Salad', 'image': 'assets/images/foods/salad.png'},
    {'name': 'Pad Krapow', 'image': 'assets/images/foods/pad.png'},
    {'name': 'Spaghetti', 'image': 'assets/images/foods/spaghetti.png'},
    {'name': 'Steak', 'image': 'assets/images/foods/steak.png'},
    {'name': 'Fried Rice', 'image': 'assets/images/foods/fried_rice.png'},
    // ADD immages later
    {'name': 'Massaman', 'image': 'assets/images/foods/pad.png'},
    {'name': 'Tom Yum Goong', 'image': 'assets/images/foods/soup.png'},
    {'name': 'Green Curry', 'image': 'assets/images/foods/soup.png'},
    {'name': 'Tom Kha Gai', 'image': 'assets/images/foods/soup.png'},
    {'name': 'Khao Man Gai', 'image': 'assets/images/foods/fried_rice.png'},
    {'name': 'Khao Moo Daeng', 'image': 'assets/images/foods/pad.png'},
    {'name': 'Boat Noodles', 'image': 'assets/images/foods/noodle.png'},
    {'name': 'Pad See Ew', 'image': 'assets/images/foods/noodle.png'},
    {'name': 'Pad Kee Mao', 'image': 'assets/images/foods/pad.png'},
    {'name': 'Larb', 'image': 'assets/images/foods/pad.png'},
    {'name': 'Omelette Rice', 'image': 'assets/images/foods/omelette.png'},
  ];

  String _meatImage(String meat) {
  switch (meat) {
    case 'Beef':
      return 'assets/images/foods/meat.png';
    case 'Chicken':
      return 'assets/images/foods/chicken.png';
    case 'Pork':
      return 'assets/images/foods/pork.png';
    case 'Fish':
      return 'assets/images/foods/fish.png';
    default:
    // add more cases as needed
      return 'assets/images/foods/example.jpg';
  }
}

  final PageController _meatController = PageController(viewportFraction: 0.6);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? selectedFood;
  String? selectedMeat;
  List<String> availableVariants = [];
  double? carbon;

  // ---------------- Fetch carbon from DB ----------------
  Future<void> _selectMeat(String meat) async {
    final value = await DBHelper.instance.getFoodCarbon(
      selectedFood!,
      meat,
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
        // Date are now set to yesterday for better statistic visualization
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
              _buildHeaderCard(),
              const SizedBox(height: 25),
              _sectionTitle('Select food'),
              _foodSearchBox(),
              const SizedBox(height: 15),
              _foodList(),

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

  Widget _foodSearchBox() {
  return TextField(
    controller: _searchController,
    onChanged: (value) {
      setState(() {
        _searchQuery = value.toLowerCase();
      });
    },
    decoration: InputDecoration(
      hintText: 'Search food...',
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      ),
    );
  }

  Widget _foodList() {
    final filteredFoods =
        foods.where((food) {
          return food['name']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        }).toList();

    const int initialItemCount = 6;
    final displayedFoods =
        _showAllFoods
            ? filteredFoods
            : filteredFoods.take(initialItemCount).toList();

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedFoods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final food = displayedFoods[index];
            final isSelected = selectedFood == food['name'];
            return GestureDetector(
              onTap: () => _selectFood(food['name']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
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
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        food['image']!,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: Text(
                        food['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
            );
          },
        ),

        // Show More / Less Button
        if (filteredFoods.length > initialItemCount)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllFoods = !_showAllFoods;
              });
            },
            child: Text(
              _showAllFoods ? 'Show Less ▲' : 'Show More ▼',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 15, 89, 91)),
            ),
          ),
      ],
    );
  }

  Widget _meatSlider() {
    if (availableVariants.isEmpty) return const SizedBox();
    return SizedBox(
      height: 190,
      child: Stack(
        children: [
          PageView.builder(
            controller: _meatController,
            itemCount: availableVariants.length,
            onPageChanged: (index) {
              _selectMeat(availableVariants[index]);
            },
            itemBuilder: (context, index) {
              final meatName = availableVariants[index];
              final isSelected = selectedMeat == meatName;

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
                    Image.asset(_meatImage(meatName), height: 80),
                    const SizedBox(height: 10),
                    Text(
                      meatName,
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

  void _selectFood(String food) async {
  setState(() {
    selectedFood = food;
    selectedMeat = null;
    carbon = null;
    availableVariants = [];
  });

  if (food == 'Salad') {
    _selectMeat('');
    return;
  }

  final variants = await DBHelper.instance.getFoodVariants(food);

  setState(() {
    availableVariants = variants;
  });

  if (variants.length == 1) {
    _selectMeat(variants.first);
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