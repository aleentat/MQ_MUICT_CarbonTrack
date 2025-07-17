import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/waste_diary_entry.dart';

class CarbonDiaryPage extends StatefulWidget {
  @override
  _CarbonDiaryPageState createState() => _CarbonDiaryPageState();
}

class _CarbonDiaryPageState extends State<CarbonDiaryPage> {
  List<WasteDiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _addDiaryEntry(WasteDiaryEntry entry) async {
    await DBHelper.instance.insertWasteDiaryEntry(entry);
    await _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DBHelper.instance.getAllWasteDiaryEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _entries = entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<WasteDiaryEntry>> grouped = {};
    for (var entry in _entries) {
      String date = DateFormat('y-MM-dd').format(entry.timestamp);
      grouped.putIfAbsent(date, () => []).add(entry);
    }

    return Scaffold(
      backgroundColor: Color(0xFFFCFAF2),
      appBar: AppBar(
        title: Text('Carbon Diary Log'),
        backgroundColor: Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
      ),
      body: grouped.isEmpty
          ? Center(
              child: Text(
                'No entries yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Text(
                        DateFormat('EEEE, MMMM d, y').format(
                          DateTime.parse(entry.key),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C6A4F),
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (log) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            leading: Icon(
                              Icons.recycling,
                              color: Color(0xFF4C6A4F),
                            ),
                            title: Text(
                              '${log.name} → ${log.type}',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              DateFormat.Hm().format(log.timestamp),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
    );
  }
}