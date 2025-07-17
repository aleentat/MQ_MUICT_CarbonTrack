import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';

class WasteSortingGuide extends StatefulWidget {
  @override
  _WasteSortingGuideState createState() => _WasteSortingGuideState();
}

class _WasteSortingGuideState extends State<WasteSortingGuide> {
  List<WasteItem> _allItems = [];
  String? _selectedCategory;
  String? _selectedSubcategory;

  final Map<String, List<String>> _subcategoryMap = {
    'Plastic': ['Bottle', 'Bag', 'Foam'],
    'Glass': ['Bottle', 'Jar', 'Broken Glass'],
    'Metal': ['Can', 'Foil'],
    'Paper': ['Newspaper', 'Cardboard', 'Tissue', 'Mixed Paper'],
    'Food': ['Fruit', 'Leftovers', 'Shells & Bones'],
    'Other': ['Battery', 'Cloth', 'E-Waste ', 'Hazardous'],
  };

  final Map<String, String> _categoryImages = {
    'Plastic': 'assets/images/plastic.png',
    'Glass': 'assets/images/glass.png',
    'Metal': 'assets/images/metal.png',
    'Paper': 'assets/images/paper.png',
    'Food': 'assets/images/food.png',
    'Other': 'assets/images/other.png',
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await DBHelper.instance.getWasteItems();
      setState(() {
        _allItems = items;
      });
    } catch (e) {
      print('Error loading items: $e');
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
    });
  }

  void _onSubcategorySelected(String subcategory) {
    setState(() {
      _selectedSubcategory = subcategory;
    });
  }

  Future<void> _addToDiary(WasteItem item) async {
    final entry = WasteDiaryEntry(
      id: 0,
      name: item.name,
      type: item.type,
      timestamp: DateTime.now(),
    );

    try {
      await DBHelper.instance.insertWasteDiaryEntry(entry);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.name} added to diary')));
    } catch (e) {
      print('Failed to save diary entry: $e');
    }
  }

  List<WasteItem> getFilteredItems() {
    return _allItems.where((item) {
      final matchCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchSubcategory =
          _selectedSubcategory == null ||
          item.subcategory == _selectedSubcategory;
      return matchCategory && matchSubcategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = getFilteredItems();
    final categories = _categoryImages.keys.toList();
    final subcategories =
        _selectedCategory != null
            ? _subcategoryMap[_selectedCategory!] ?? []
            : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF2),
      appBar: AppBar(
        title: const Text('Waste Sorting Guide'),
        backgroundColor: const Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Grid
              GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children:
                    categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => _onCategorySelected(category),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF4C6A4F)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4C6A4F)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                _categoryImages[category]!,
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF4C6A4F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 8),

              // Subcategory
              if (subcategories.isNotEmpty)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final sub = subcategories[index];
                      final isSelected = _selectedSubcategory == sub;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            sub,
                            style: const TextStyle(fontSize: 13),
                          ),
                          selected: isSelected,
                          onSelected: (_) => _onSubcategorySelected(sub),
                          selectedColor: const Color(0xFF4C6A4F),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // Filtered List
              filteredItems.isEmpty
                  ? const Center(child: Text('No items found.'))
                  : ListView.separated(
                    itemCount: filteredItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          leading: const Icon(
                            Icons.recycling,
                            color: Color(0xFF4C6A4F),
                            size: 24,
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type: ${item.type}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (item.tip.isNotEmpty)
                                Text(
                                  'Tip: ${item.tip}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Color(0xFF4C6A4F),
                              size: 24,
                            ),
                            onPressed: () => _addToDiary(item),
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
      
    );
  }
}
