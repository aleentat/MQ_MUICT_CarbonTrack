import 'package:flutter/material.dart';

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
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedItem != null)
              Text(
                'Sort as: ${wasteGuide[_selectedItem]!}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
