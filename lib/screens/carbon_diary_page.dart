import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../database/db_helper.dart';
import '../models/waste_diary_entry.dart';
import '../models/travel_diary_entry.dart';

class CarbonDiaryPage extends StatefulWidget {
  @override
  _CarbonDiaryPageState createState() => _CarbonDiaryPageState();
}

class _CarbonDiaryPageState extends State<CarbonDiaryPage> {
  List<UnifiedDiaryEntry> _combinedEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final waste = await DBHelper.instance.getAllWasteDiaryEntries();
    final travel = await DBHelper.instance.getAllTravelDiaryEntries();
    print("🗑️ Loaded ${waste.length} waste entries");
    print("🚗 Loaded ${travel.length} travel entries");

    List<UnifiedDiaryEntry> combined = [
      ...waste.map((e) => UnifiedDiaryEntry(
            timestamp: e.timestamp,
            entry: e,
            type: 'waste',
          )),
      ...travel.map((e) => UnifiedDiaryEntry(
            timestamp: e.timestamp,
            entry: e,
            type: 'travel',
          )),
    ];

    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // latest first

    setState(() {
      _combinedEntries = combined;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<UnifiedDiaryEntry>> grouped = {};

    for (var entry in _combinedEntries) {
      String date = DateFormat('y-MM-dd').format(entry.timestamp);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(entry);
    }

    return Scaffold(
      backgroundColor: Color(0xFFFCFAF2),
      appBar: AppBar(
        title: Text('Carbon Diary Log'),
        backgroundColor: Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadEntries),
          IconButton(
            icon: Icon(Icons.upload_file),
            tooltip: 'Export DB',
            onPressed: () async {
              await DBHelper.instance.exportDatabase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Database exported')),
              );
            },
          ),
        ],
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
                String date = entry.key;
                List<UnifiedDiaryEntry> logs = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Text(
                        DateFormat('EEEE, MMMM d, y')
                            .format(DateTime.parse(date)),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C6A4F),
                        ),
                      ),
                    ),
                    ...logs.map((log) {
                      if (log.type == 'waste') {
                        return _buildWasteCard(log.entry as WasteDiaryEntry);
                      } else {
                        return _buildTravelCard(log.entry as TravelDiaryEntry);
                      }
                    }).toList(),
                    SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildWasteCard(WasteDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: log.imagePath != null && log.imagePath!.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: InteractiveViewer(
                          child: Image.file(File(log.imagePath!)),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.file(
                        File(log.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Icon(Icons.recycling, color: Color(0xFF4C6A4F), size: 40),
          title: Text(
            '${log.name} → ${log.type}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (log.quantity != null)
                Text('Quantity: ${log.quantity}', style: TextStyle(fontSize: 12)),
              if (log.note != null && log.note!.isNotEmpty)
                Text('Note: ${log.note}', style: TextStyle(fontSize: 12)),
              Text(
                'Time: ${DateFormat.Hm().format(log.timestamp)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTravelCard(TravelDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Icon(Icons.directions_car, color: Color(0xFF1976D2), size: 40),
          title: Text(
            '${log.startLocation} → ${log.endLocation}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distance: ${log.distance.toStringAsFixed(1)} km',
                  style: TextStyle(fontSize: 12)),
              Text('Mode: ${log.mode}', style: TextStyle(fontSize: 12)),
              Text(
                'Emission: ${log.carbon.toStringAsFixed(2)} kgCO₂',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Time: ${DateFormat.Hm().format(log.timestamp)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UnifiedDiaryEntry {
  final DateTime timestamp;
  final dynamic entry; // WasteDiaryEntry / TravelDiaryEntry
  final String type;   // waste / travel

  UnifiedDiaryEntry({
    required this.timestamp,
    required this.entry,
    required this.type,
  });
}