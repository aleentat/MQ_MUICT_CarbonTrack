import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarbonLogEntry {
  final String type; // 'travel' or 'waste'
  final String description;
  final DateTime timestamp;

  CarbonLogEntry({
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

class CarbonDiaryPage extends StatelessWidget {
  static List<CarbonLogEntry> logs = [];

  @override
  Widget build(BuildContext context) {
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    Map<String, List<CarbonLogEntry>> grouped = {};
    for (var log in logs) {
      String date = DateFormat('y-MM-dd').format(log.timestamp);
      grouped.putIfAbsent(date, () => []).add(log);
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
                              log.type == 'travel'
                                  ? Icons.directions_car
                                  : Icons.recycling,
                              color: Color(0xFF4C6A4F),
                            ),
                            title: Text(
                              log.description,
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