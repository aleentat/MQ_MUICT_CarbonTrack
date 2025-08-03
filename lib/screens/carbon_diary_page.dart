import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _filter = 'all'; // all, waste, travel
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Set<DateTime> _daysWithEntries = {};

  Future<void> _loadEntries() async {
    final waste = await DBHelper.instance.getAllWasteDiaryEntries();
    final travel = await DBHelper.instance.getAllTravelDiaryEntries();
    print("🗑️ Loaded ${waste.length} waste entries");
    print("🚗 Loaded ${travel.length} travel entries");

    List<UnifiedDiaryEntry> combined = [
      ...waste.map(
        (e) =>
            UnifiedDiaryEntry(timestamp: e.timestamp, entry: e, type: 'waste'),
      ),
      ...travel.map(
        (e) =>
            UnifiedDiaryEntry(timestamp: e.timestamp, entry: e, type: 'travel'),
      ),
    ];

    _daysWithEntries =
        combined
            .map(
              (e) => DateTime(
                e.timestamp.year,
                e.timestamp.month,
                e.timestamp.day,
              ),
            )
            .toSet();
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _combinedEntries = combined;
    });
  }

  List<UnifiedDiaryEntry> _getFilteredLogsForSelectedDay() {
    if (_selectedDay == null) return [];

    String selectedDate = DateFormat('y-MM-dd').format(_selectedDay!);
    return _combinedEntries.where((entry) {
      String entryDate = DateFormat('y-MM-dd').format(entry.timestamp);
      bool dateMatch = entryDate == selectedDate;
      bool typeMatch = _filter == 'all' || _filter == entry.type;
      return dateMatch && typeMatch;
    }).toList();
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Database exported')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          SizedBox(height: 10),
          _buildFilterChips(),
          SizedBox(height: 10),
          Expanded(
            child:
                _selectedDay == null
                    ? Center(child: Text("Select a date to view entries"))
                    : _getFilteredLogsForSelectedDay().isEmpty
                    ? Center(child: Text("No entries for selected date"))
                    : ListView(
                      children: [
                        _buildDailySummary(_getFilteredLogsForSelectedDay()),
                        ..._getFilteredLogsForSelectedDay().map((log) {
                          return log.type == 'waste'
                              ? _buildWasteCard(log.entry as WasteDiaryEntry)
                              : _buildTravelCard(log.entry as TravelDiaryEntry);
                        }).toList(),
                      ],
                    ),
          ),
        ],
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
          leading:
              log.imagePath != null &&
                      log.imagePath!.isNotEmpty &&
                      File(log.imagePath!).existsSync()
                  ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => Dialog(
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
                        width: 40,
                        height: 40,
                        child: Image.file(
                          File(log.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  : Icon(Icons.recycling, color: Color(0xFF4C6A4F), size: 30),
          title: Text(
            log.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (log.quantity != null)
                Text('Qty: ${log.quantity}', style: TextStyle(fontSize: 12)),
              if (log.note != null && log.note!.isNotEmpty)
                Text('Note: ${log.note}', style: TextStyle(fontSize: 12)),
              Text(
                DateFormat.Hm().format(log.timestamp),
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
        elevation: 3,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Icon(
            Icons.directions_car_filled,
            color: Color(0xFF1976D2),
            size: 30,
          ),
          title: Text(
            '${log.startLocation} → ${log.endLocation}',
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${log.carbon.toStringAsFixed(2)} kgCO₂ | ${log.distance.toStringAsFixed(1)} km | ${log.mode}',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                DateFormat.Hm().format(log.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySummary(List<UnifiedDiaryEntry> logs) {
    int wasteCount = 0; // quantity
    int travelCount = 0; // log
    double totalCarbon = 0.0;

    for (var log in logs) {
      if (log.type == 'waste') {
        final wasteEntry = log.entry as WasteDiaryEntry;
        wasteCount+= wasteEntry.quantity;
      } else if (log.type == 'travel') {
        travelCount++;
        final travelEntry = log.entry as TravelDiaryEntry;
        totalCarbon += travelEntry.carbon;
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
            SizedBox(width: 8),
            Text(
              '♻️ $wasteCount  |  🚗 $travelCount  |  💨 ${totalCarbon.toStringAsFixed(2)} kgCO₂',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text("All"),
          selected: _filter == 'all',
          onSelected: (_) => setState(() => _filter = 'all'),
        ),
        SizedBox(width: 8),
        ChoiceChip(
          label: Text("Waste"),
          selected: _filter == 'waste',
          onSelected: (_) => setState(() => _filter = 'waste'),
        ),
        SizedBox(width: 8),
        ChoiceChip(
          label: Text("Travel"),
          selected: _filter == 'travel',
          onSelected: (_) => setState(() => _filter = 'travel'),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: HeaderStyle(formatButtonVisible: false),
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_daysWithEntries.contains(
              DateTime(date.year, date.month, date.day),
            )) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

class UnifiedDiaryEntry {
  final DateTime timestamp;
  final dynamic entry; // WasteDiaryEntry / TravelDiaryEntry
  final String type; // waste / travel

  UnifiedDiaryEntry({
    required this.timestamp,
    required this.entry,
    required this.type,
  });
}
