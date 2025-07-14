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
  List<WasteItem> _filteredItems = [];
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = ['Plastic', 'Glass', 'Metal', 'Paper', 'Food', 'Other'];

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
      _applyFilters();
    } catch (e) {
      print('Error loading items: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchCategory = _selectedCategory == null || item.category == _selectedCategory;
        final matchSearch = _searchQuery.isEmpty || item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCategory && matchSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // toggle off
    } else {
      _selectedCategory = category;
    }
    _applyFilters();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} added to diary')),
      );
    } catch (e) {
      print('Failed to save diary entry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF2),
      appBar: AppBar(
        title: const Text('Waste Sorting Guide'),
        backgroundColor: const Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search waste item...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Category Grid
            SizedBox(
              height: 120,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4C6A4F) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF4C6A4F)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _categoryImages[category]!,
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF4C6A4F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Results
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('No items found.'))
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.recycling, color: Color(0xFF4C6A4F)),
                            title: Text(item.name),
                            subtitle: Text('Type: ${item.type}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Color(0xFF4C6A4F)),
                              onPressed: () => _addToDiary(item),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}