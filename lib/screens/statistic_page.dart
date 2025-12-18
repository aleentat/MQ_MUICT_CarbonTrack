import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _selectedTimeframe = 'Weekly';
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
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSegmentedControl(
                    label: 'Type',
                    options: dataTypes,
                    selected: _selectedDataType,
                    onSelected: (val) {
                      setState(() => _selectedDataType = val);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSegmentedControl(
                    label: 'View',
                    options: timeframes,
                    selected: _selectedTimeframe,
                    onSelected: (val) {
                      setState(() => _selectedTimeframe = val);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF4C6A4F)),
                  onPressed: _goToPreviousPeriod,
                ),
                Text(
                  _getSelectedRangeText(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Color(0xFF4C6A4F)),
                  onPressed: _goToNextPeriod,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBarChart(dataMap),
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(dataMap, prevMap),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl({
    required String label,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color.fromARGB(255, 33, 98, 73),
          ),
        ),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(
              isSelected: options.map((e) => e == selected).toList(),
              onPressed: (index) => onSelected(options[index]),
              borderRadius: BorderRadius.circular(30),
              selectedColor: Colors.white,
              color: const Color(0xFF4C6A4F),
              fillColor: const Color(0xFF4C6A4F),
              borderColor: Colors.black,
              selectedBorderColor: Colors.black,
              constraints: const BoxConstraints(minHeight: 30, minWidth: 55),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              children:
                  options.map((e) {
                    final isSelected = e == selected;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF4C6A4F) : Colors.white,
                      ),
                      child: Text(e),
                    );
                  }).toList(),
            ),
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
    final unit = _selectedDataType == 'Travel' ? 'kg CO₂' : 'pcs';

    Color diffColor = isIncrease ? Colors.red : Colors.green;
    Icon diffIcon =
        isIncrease
            ? Icon(Icons.arrow_upward, color: diffColor, size: 18)
            : Icon(Icons.arrow_downward, color: diffColor, size: 18);

    double progress = (avg / (maxVal * 1.2)).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 255, 252),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4C6A4F), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📍 Highlights",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 34, 70, 43),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                "Total: ${total.toStringAsFixed(2)} $unit",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              diffIcon,
              Text(
                "${percent.abs().toStringAsFixed(1)}%",
                style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
              ),
              Text(
                "compared to ${_getPreviousLabel()}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Average per unit time: ${avg.toStringAsFixed(2)} $unit",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            color: Color(0xFF4C6A4F),
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniBarWithLabel("Max", maxVal, maxVal, unit, Colors.redAccent),
              _miniBarWithLabel("Min", minVal, maxVal, unit, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBarWithLabel(
    String label,
    double value,
    double maxValue,
    String unit,
    Color color,
  ) {
    double barWidth = 100 * (value / maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        Text("$label: ${value.toStringAsFixed(2)} $unit"),
        const SizedBox(width: 8),
        Container(
          width: barWidth,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  // double _calculateMaxY(Map<String, double> dataMap) {
  //   if (dataMap.isEmpty) return 1;
  //   return dataMap.values.reduce((a, b) => a > b ? a : b);
  // }

  double _calculateMaxY(Map<String, double> data) {
    final maxY = data.values.isEmpty ? 0 : data.values.reduce(max);
    return maxY * 1.3;
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
            color: const Color.fromARGB(255, 84, 133, 117),
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: value * 1.1,
              color: Color(0xFFC8E6C9),
            ),
          ),
        ],
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: max(labels.length * 30.0, MediaQuery.of(context).size.width),
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxY(dataMap),
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
                tooltipBgColor: const Color.fromARGB(221, 38, 60, 58),
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
