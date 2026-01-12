import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';
import '../utils/info_popup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WasteSortingGuide extends StatefulWidget {
  @override
  _WasteSortingGuideState createState() => _WasteSortingGuideState();
}

class _WasteSortingGuideState extends State<WasteSortingGuide> {
  List<WasteItem> _allItems = [];
  String? _selectedCategory;
  String? _selectedSubcategory;
  String searchQuery = '';

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

  Color getTypeColor(String type) {
    switch (type) {
      case 'Recyclable':
        return const Color.fromARGB(255, 240, 216, 1);
      case 'Compost':
        return const Color.fromARGB(255, 79, 205, 85);
      case 'Trash':
        return const Color.fromARGB(255, 21, 85, 223);
      case 'Hazardous':
        return const Color.fromARGB(255, 255, 7, 7);
      default:
        return Colors.grey.shade400;
    }
  }

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
    if (searchQuery.isNotEmpty) {
      return _allItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Add "${item.name}"\nCarbon Emission: ${item.ef * item.unit} gCO2e',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C6A4F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          filled: true,
                          fillColor: const Color(0xFFFCFAF2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

                      // Note
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Note (optional)',
                          filled: true,
                          fillColor: const Color(0xFFFCFAF2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                              final pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                final tempImage = File(pickedFile.path);
                                final savedPath = await saveImagePermanently(
                                  tempImage,
                                );
                                setModalState(() {
                                  imageFile = File(savedPath);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text('Pick Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF44765F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (imageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imageFile!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final entry = WasteDiaryEntry(
                                  name: item.name,
                                  type: item.type,
                                  timestamp: DateTime.now(),
                                  quantity: quantity,
                                  note: note,
                                  imagePath: imageFile?.path,
                                  unit: item.unit,
                                  carbon: item.ef / 1000 * quantity * item.unit,
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
                                        backgroundColor: const Color(
                                          0xFF4C6A4F,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Failed to save diary entry: $e');
                                }
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF44765F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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

  Future<String> saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = p.basename(image.path);
    final newPath = '${directory.path}/$name';

    if (!File(newPath).existsSync()) {
      await image.copy(newPath);
    }
    return newPath;
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/gif/waste.gif', height: 90),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Track your travel footprint 🚗\nEvery trip counts',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = getFilteredItems();
    final categories = _categoryImages.keys.toList();
    final subcategories =
        _selectedCategory != null
            ? _subcategoryMap[_selectedCategory!] ?? []
            : [];
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
            'Waste Calculator',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 25),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search waste item...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF4C6A4F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF4C6A4F),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                              border: Border.all(
                                color: const Color(0xFF4C6A4F),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        _categoryImages[category]!,
                                        height: 30,
                                        width: 30,
                                      ),
                                      const SizedBox(height: 8),
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
                                // info (i)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) =>
                                                InfoPopup(category: category),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.white.withOpacity(0.3)
                                                : Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
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

                const SizedBox(height: 12),

                // Filtered List
                _selectedCategory == 'Symbol Guide'
                    ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF4C6A4F)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(item.type, width: 50, height: 50),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item.tip,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFF4C6A4F),
                                ),
                                onPressed: () => _addToDiary(item),
                                tooltip: 'Add to diary',
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
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 9),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getTypeColor(
                                      item.type,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: getTypeColor(item.type),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Type: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          item.type,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  // decoration: BoxDecoration(
                                  //   color: Color(0xFFEEF3EA),
                                  //   borderRadius: BorderRadius.circular(8),
                                  // ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.tips_and_updates,
                                        size: 16,
                                        color: Color(0xFF4C6A4F),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.tip,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF4C6A4F),
                              ),
                              onPressed: () => _addToDiary(item),
                              tooltip: 'Add to diary',
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
