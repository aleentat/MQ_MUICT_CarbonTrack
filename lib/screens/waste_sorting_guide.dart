import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart'; // NEW import

class WasteSortingGuide extends StatefulWidget {
  @override
  _WasteSortingGuideState createState() => _WasteSortingGuideState();
}

class _WasteSortingGuideState extends State<WasteSortingGuide> {
  List<WasteItem> _items = [];
  WasteItem? _selectedItem;
  bool _calculated = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await DBHelper.instance.getWasteItems();
      setState(() {
        _items = items;
      });
    } catch (e) {
      print('Error loading items: $e');
    }
  }

  void _onItemSelected(WasteItem? value) {
    setState(() {
      _selectedItem = value;
      _calculated = value != null;
    });
  }

  Future<void> _addToDiary() async {
    if (!_calculated || _selectedItem == null) return;

    final entry = WasteDiaryEntry(
      id: 0, // Will be auto-incremented
      name: _selectedItem!.name,
      type: _selectedItem!.type,
      timestamp: DateTime.now(),
    );

    try {
      await DBHelper.instance.insertWasteDiaryEntry(entry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry saved to diary')),
      );
    } catch (e) {
      print('Failed to save diary entry: $e');
    }

    setState(() {
      _selectedItem = null;
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
            Text('Waste Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<WasteItem>(
                value: _items.contains(_selectedItem) ? _selectedItem : null,
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select an item'),
                items: _items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.name),
                  );
                }).toList(),
                onChanged: _onItemSelected,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sorting Result: ${_selectedItem?.type ?? '-'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculated ? _addToDiary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calculated ? Color(0xFF4C6A4F) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Add to Diary', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}