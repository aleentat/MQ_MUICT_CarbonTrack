import 'package:flutter/material.dart';
import 'carbon_log_entry.dart';
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

  void _confirmSelection() {
    if (_selectedItem != null && _selectedCategory != null) {
      CarbonDiaryPage.logs.add(CarbonLogEntry(
        type: 'waste',
        description: '$_selectedItem → $_selectedCategory',
        timestamp: DateTime.now(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry added to diary')),
      );
      setState(() {
        _selectedItem = null;
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waste Sorting Guide')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select an item'),
              value: _selectedItem,
              items: wasteGuide.keys.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                  _selectedCategory = value != null ? wasteGuide[value] : null;
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedCategory != null)
              Column(
                children: [
                  Text(
                    'Sort as: $_selectedCategory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _confirmSelection,
                    child: Text('Add to Diary'),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}