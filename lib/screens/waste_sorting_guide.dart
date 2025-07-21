import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    'Food': ['Fruit/Vegetable', 'Leftovers', 'Shells & Bones'],
    'Textile': ['Clothing', 'Household Fabric', 'Fabric Waste', 'Footwear'],
    'Other': ['Battery', 'E-Waste ', 'Hazardous'],
    'Symbol Guide': ['Recyclable Plastic', 'Non-Recyclable'],
  };

  final Map<String, String> _categoryImages = {
    'Plastic': 'assets/images/plastic.png',
    'Glass': 'assets/images/glass.png',
    'Metal': 'assets/images/metal.png',
    'Paper': 'assets/images/paper.png',
    'Food': 'assets/images/food.png',
    'Textile': 'assets/images/textile.png',
    'Other': 'assets/images/other.png',
    'Symbol Guide': 'assets/images/symbol.png',
  };

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _showAddEntryBottomSheet(WasteItem item) async {
    final _formKey = GlobalKey<FormState>();
    int quantity = 1;
    String note = '';
    File? imageFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add "${item.name}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quantity input
                      TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Enter a valid number > 0';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          final n = int.tryParse(val);
                          if (n != null && n > 0) quantity = n;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Note input
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (val) {
                          note = val;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Image picker
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? picked = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  imageFile = File(picked.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text('Pick Image'),
                          ),
                          const SizedBox(width: 12),
                          if (imageFile != null)
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final entry = WasteDiaryEntry(
                                  name: item.name,
                                  type: item.type,
                                  timestamp: DateTime.now(),
                                  quantity: quantity,
                                  note: note,
                                  imagePath: imageFile?.path,
                                );
                                try {
                                  await DBHelper.instance.insertWasteDiaryEntry(
                                    entry,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added to diary: ${item.name}',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Failed to save diary entry: $e');
                                }
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addToDiary(WasteItem item) async {
    await _showAddEntryBottomSheet(item);
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
                crossAxisCount: 4,
                childAspectRatio: 0.85,
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

              const SizedBox(height: 3),

              // Subcategory Chips
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
              _selectedCategory == 'Symbol Guide'
                  ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF4C6A4F)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              (item.type),
                              width: 48,
                              height: 48,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.sortingTips != null)
                              Text(
                                item.sortingTips!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                  : filteredItems.isEmpty
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
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF4C6A4F)),
                        ),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.sortingTips ?? ''),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C6A4F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Add'),
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
