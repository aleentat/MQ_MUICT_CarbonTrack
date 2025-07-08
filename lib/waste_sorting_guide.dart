import 'package:flutter/material.dart';
import 'carbon_diary_page.dart';

class WasteSortingGuide extends StatefulWidget {
  @override
  _WasteSortingGuideState createState() => _WasteSortingGuideState();
}

class _WasteSortingGuideState extends State<WasteSortingGuide> {
  final Map<String, String> wasteGuide = {
    'Apple Core': 'Compost',
    'Plastic Bottle': 'Recyclable',
    'Aluminum Can': 'Recyclable',
    'Pizza Box (Greasy)': 'Trash',
    'Cardboard': 'Recyclable',
    'Banana Peel': 'Compost',
    'Plastic Bag': 'Trash',
    'Glass Bottle': 'Recyclable',
    'Tissue': 'Trash',
  };

  String? _selectedItem;
  String? _selectedCategory;
  bool _calculated = false;

  void _onItemSelected(String? value) {
    setState(() {
      _selectedItem = value;
      _selectedCategory = value != null ? wasteGuide[value] : null;
      _calculated = _selectedCategory != null;
    });
  }

  void _addToDiary() {
    if (!_calculated) return;

    CarbonDiaryPage.logs.add(
      CarbonLogEntry(
        type: 'waste',
        description: '$_selectedItem → $_selectedCategory',
        timestamp: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry added to diary')),
    );

    setState(() {
      _selectedItem = null;
      _selectedCategory = null;
      _calculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF2),
      appBar: AppBar(
        title: Text('Waste Sorting Guide'),
        backgroundColor: Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waste Item',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: _selectedItem,
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select an item'),
                items: wasteGuide.keys.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: _onItemSelected,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sorting Result: ${_selectedCategory ?? '-'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculated ? _addToDiary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _calculated ? Color(0xFF4C6A4F) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Add to Diary',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
