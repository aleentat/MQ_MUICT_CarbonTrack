import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'dart:math';
import '../models/usage_summary.dart';
import '../services/api_service.dart';
import 'dart:convert';


class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  String _selectedDataType = 'Travel';
  String _selectedTimeframe = 'Monthly';
  DateTime _currentViewDate = DateTime.now();

  Map<String, double> travelData = {};
  Map<String, double> wasteData = {};
  Map<String, double> prevTravelData = {};
  Map<String, double> prevWasteData = {};

  final List<String> dataTypes = ['Travel', 'Waste'];
  final List<String> timeframes = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

// SENDING STATISTICS TO BACKEND
Future<void> _sendCurrentStatistics() async {
  final dataMap =
      _selectedDataType == 'Travel' ? travelData : wasteData;

  if (dataMap.isEmpty) return;

  final total = dataMap.values.fold(0.0, (a, b) => a + b);
  final totalLogs = dataMap.length;
  final avgDailyCO2 = totalLogs == 0 ? 0.0 : total / totalLogs;

  final summary = UsageSummary(
    userId: 'userAt${DateTime.now().millisecondsSinceEpoch}',
    date: DateTime.now().toIso8601String().split('T').first,
    totalLogs: totalLogs,
    avgDailyCO2: avgDailyCO2,
    ecoScore: _calculateEcoScore(avgDailyCO2),
  );

  final success = await ApiService.sendSummary(summary);
  if (!success) {
    // print error details to console
    print('Failed to send summary: ${jsonEncode(summary.toJson())}');
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? 'Summary sent successfully'
            : 'Failed to send summary',
      ),
    ),
  );
}

int _calculateEcoScore(double avgCO2) {
  if (avgCO2 <= 5) return 0;
  if (avgCO2 <= 8) return 1;
  if (avgCO2 <= 12) return 2;
  return 3;
}

  Future<void> _loadData() async {
    final travelEntries = await DBHelper.instance.getAllTravelDiaryEntries();
    final wasteEntries = await DBHelper.instance.getAllWasteDiaryEntries();

    Map<String, double> newTravelData = {};
    Map<String, double> newWasteData = {};
    Map<String, double> oldTravelData = {};
    Map<String, double> oldWasteData = {};

    for (var entry in travelEntries) {
      if (_isInRange(entry.timestamp, _currentViewDate)) {
        final key = _formatKey(entry.timestamp);
        newTravelData[key] = (newTravelData[key] ?? 0) + entry.carbon;
      } else if (_isInRange(entry.timestamp, _getPreviousViewDate())) {
        final key = _formatKey(entry.timestamp);
        oldTravelData[key] = (oldTravelData[key] ?? 0) + entry.carbon;
      }
    }

    for (var entry in wasteEntries) {
      if (_isInRange(entry.timestamp, _currentViewDate)) {
        final key = _formatKey(entry.timestamp);
        newWasteData[key] = (newWasteData[key] ?? 0) + entry.quantity;
      } else if (_isInRange(entry.timestamp, _getPreviousViewDate())) {
        final key = _formatKey(entry.timestamp);
        oldWasteData[key] = (oldWasteData[key] ?? 0) + entry.quantity;
      }
    }

    setState(() {
      travelData = newTravelData;
      wasteData = newWasteData;
      prevTravelData = oldTravelData;
      prevWasteData = oldWasteData;
    });
  }

  bool _isInRange(DateTime timestamp, DateTime refDate) {
    late DateTime start, end;

    switch (_selectedTimeframe) {
      case 'Weekly':
        start = refDate.subtract(Duration(days: refDate.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'Monthly':
        start = DateTime(refDate.year, refDate.month, 1);
        end = DateTime(refDate.year, refDate.month + 1, 0);
        break;
      case 'Yearly':
        start = DateTime(refDate.year, 1, 1);
        end = DateTime(refDate.year, 12, 31);
        break;
      default:
        return false;
    }

    return !timestamp.isBefore(start) && !timestamp.isAfter(end);
  }

  DateTime _getPreviousViewDate() {
    switch (_selectedTimeframe) {
      case 'Weekly':
        return _currentViewDate.subtract(const Duration(days: 7));
      case 'Monthly':
        return DateTime(_currentViewDate.year, _currentViewDate.month - 1, 1);
      case 'Yearly':
        return DateTime(_currentViewDate.year - 1, 1, 1);
      default:
        return _currentViewDate;
    }
  }

  void _goToPreviousPeriod() {
    setState(() {
      switch (_selectedTimeframe) {
        case 'Weekly':
          _currentViewDate = _currentViewDate.subtract(const Duration(days: 7));
          break;
        case 'Monthly':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month - 1,
            1,
          );
          break;
        case 'Yearly':
          _currentViewDate = DateTime(_currentViewDate.year - 1, 1, 1);
          break;
      }
    });
    _loadData();
  }

  void _goToNextPeriod() {
    setState(() {
      switch (_selectedTimeframe) {
        case 'Weekly':
          _currentViewDate = _currentViewDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month + 1,
            1,
          );
          break;
        case 'Yearly':
          _currentViewDate = DateTime(_currentViewDate.year + 1, 1, 1);
          break;
      }
    });
    _loadData();
  }

  String _formatKey(DateTime timestamp) {
    switch (_selectedTimeframe) {
      case 'Weekly':
        return DateFormat('E').format(timestamp); // Mon, Tue, ...
      case 'Monthly':
        return '${timestamp.day}'; // '1', '2', ..., '31'
      case 'Yearly':
        return DateFormat('MMM').format(timestamp); // Jan, Feb, ...
      default:
        return '';
    }
  }

  String _monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month];
  }

  String _getPreviousLabel() {
    switch (_selectedTimeframe) {
      case 'Weekly':
        return 'last week';
      case 'Monthly':
        return 'last month';
      case 'Yearly':
        return 'last year';
      default:
        return '';
    }
  }

  String _getSelectedRangeText() {
    DateTime start, end;
    final d = _currentViewDate;

    switch (_selectedTimeframe) {
      case 'Weekly':
        start = d.subtract(Duration(days: d.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'Monthly':
        start = DateTime(d.year, d.month, 1);
        end = DateTime(d.year, d.month + 1, 0);
        break;
      case 'Yearly':
        start = DateTime(d.year, 1, 1);
        end = DateTime(d.year, 12, 31);
        break;
      default:
        return '';
    }

    String format(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';
    return '${format(start)} - ${format(end)}';
  }

  List<String> _generateLabelsForCurrentView() {
    switch (_selectedTimeframe) {
      case 'Weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Monthly':
        final lastDay =
            DateTime(_currentViewDate.year, _currentViewDate.month + 1, 0).day;
        return List.generate(lastDay, (i) => '${i + 1}');
      case 'Yearly':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = _selectedDataType == 'Travel' ? travelData : wasteData;
    final prevMap =
        _selectedDataType == 'Travel' ? prevTravelData : prevWasteData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: const Color(0xFF4C6A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Send summary',
            onPressed: _sendCurrentStatistics,
          ),
          IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          ),
          ],
          ),
      backgroundColor: const Color(0xFFFCFAF2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Type',
                    _selectedDataType,
                    dataTypes,
                    (val) => setState(() => _selectedDataType = val),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDropdown(
                    'View',
                    _selectedTimeframe,
                    timeframes,
                    (val) {
                      setState(() {
                        _selectedTimeframe = val;
                      });
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _goToPreviousPeriod,
                ),
                Text(
                  _getSelectedRangeText(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _goToNextPeriod,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(child: _buildBarChart(dataMap)),
            const SizedBox(height: 30),
            _buildSummaryCard(dataMap, prevMap),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String selected,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            underline: const SizedBox(),
            items:
                options
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (val) => onChanged(val!),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    Map<String, double> dataMap,
    Map<String, double> prevMap,
  ) {
    if (dataMap.isEmpty) {
      return Center(
        child: Text(
          "No data in this period",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    final avg = total / dataMap.length;
    final maxVal = dataMap.values.reduce(max);
    final minVal = dataMap.values.reduce(min);

    final prevTotal = prevMap.values.fold(0.0, (a, b) => a + b);
    final diff = total - prevTotal;
    final percent = prevTotal == 0 ? 100 : (diff / prevTotal) * 100;

    final isIncrease = diff >= 0;
    final arrow = isIncrease ? '↑' : '↓';
    final unit = _selectedDataType == 'Travel' ? 'kg CO₂' : 'pcs';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📍 Highlights", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Total: ${total.toStringAsFixed(2)} $unit"),
          Text("Average: ${avg.toStringAsFixed(2)} $unit"),
          Text("Max: ${maxVal.toStringAsFixed(2)} $unit"),
          Text("Min: ${minVal.toStringAsFixed(2)} $unit"),
          Text("Compared to ${_getPreviousLabel()}: $arrow ${diff.abs().toStringAsFixed(2)} $unit (${percent.abs().toStringAsFixed(1)}%)"),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> dataMap) {
    if (dataMap.isEmpty) {
      return Center(child: Text("No graph data"));
    }

    final labels = _generateLabelsForCurrentView();
    final barGroups = List.generate(labels.length, (i) {
      final label = labels[i];
      final value = dataMap[label] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            color: const Color(0xFF4C6A4F),
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: value * 1.1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: max(labels.length * 30.0, MediaQuery.of(context).size.width),
        height: 180,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    String unit = _selectedDataType == 'Travel' ? 'kg' : 'pcs';
                    return Text(
                      '${value.toInt()} $unit',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < labels.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          labels[idx],
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final value = rod.toY;
                  return BarTooltipItem(
                    '${value.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
