import 'package:flutter/material.dart';
import 'carbon_log_entry.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(title: Text('Carbon Diary Log')),
      body: ListView(
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.parse(entry.key)),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ...entry.value.map((log) => ListTile(
                    leading: Icon(log.type == 'travel' ? Icons.directions_car : Icons.delete),
                    title: Text(log.description),
                    subtitle: Text('${DateFormat.Hm().format(log.timestamp)}'),
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
