import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'dart:math';
import '../models/usage_summary.dart';
import '../services/api_service.dart';
import 'dart:convert';
import '../utils/eco_score_calculator.dart';



class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  String _selectedDataType = 'Travel';
  String _selectedTimeframe = 'Weekly';
  DateTime _currentViewDate = DateTime.now();
  List<dynamic> travelEntries = [];
  List<dynamic> wasteEntries = [];
  List<dynamic> eatingEntries = [];
  List<dynamic> shoppingEntries = [];


  Map<String, double> travelData = {};
  Map<String, double> wasteData = {};
  Map<String, double> prevTravelData = {};
  Map<String, double> prevWasteData = {};
  Map<String, double> eatingData = {};
  Map<String, double> prevEatingData = {};
  Map<String, double> shoppingData = {};
  Map<String, double> prevShoppingData = {};

  final List<String> dataTypes = ['Travel', 'Waste', 'Eating', 'Shopping'];
  final List<String> timeframes = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

// SENDING STATISTICS TO BACKEND
Future<void> _sendCurrentStatistics() async {
  final dataMap = _selectedDataType == 'Travel'
    ? travelData
    : _selectedDataType == 'Waste'
        ? wasteData
        : _selectedDataType == 'Eating'
            ? eatingData
            : shoppingData;


  if (dataMap.isEmpty) return;

  final totalLogs = travelEntries.length + wasteEntries.length + eatingEntries.length + shoppingEntries.length;
  final double travelCO2 = travelData.values.fold(0.0, (a, b) => a + b);
  final double wasteCO2 = wasteData.values.fold(0.0, (a, b) => a + b);
  final double eatingCO2 = eatingData.values.fold(0.0, (a, b) => a + b);
  final double shoppingCO2 = shoppingData.values.fold(0.0, (a, b) => a + b);
  final totalDailyCO2 = travelCO2 + wasteCO2 + eatingCO2 + shoppingCO2;
  final username = await DBHelper.instance.getOrCreateUsername();
  final user = await DBHelper.instance.getUserProfile();
  final age = user?['age'] ?? 0;
  final appOpenCount = await DBHelper.instance.getTodayAppOpenCount();


  final summary = UsageSummary(
  userId: username,
  age: age,
  date: DateTime.now().toIso8601String().split('T').first,
  totalLogs: totalLogs,
  appOpens: appOpenCount,
  co2Breakdown: {
    'travel': travelCO2,
    'waste': wasteCO2,
    'eating': eatingCO2,
    'shopping': shoppingCO2,
  },
  totalDailyCO2: totalDailyCO2,
  ecoScore: EcoScoreCalculator.dailyScore(totalDailyCO2),
  );

  print(totalDailyCO2);
  print("--------------------");

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

int _weekOfMonth(DateTime date) {
  return ((date.day - 1) ~/ 7) + 1;
}

int _calculateWeeklyEcoScore() {
  if (_selectedTimeframe != 'Weekly') return 0;

  int weeklyScore = 0;
  travelData.forEach((_, dailyCO2) {
    weeklyScore += EcoScoreCalculator.dailyScore(dailyCO2);

  });

  wasteData.forEach((_, dailyCO2) {
    weeklyScore += EcoScoreCalculator.dailyScore(dailyCO2);

  });

  eatingData.forEach((_, dailyCO2) {
    weeklyScore += EcoScoreCalculator.dailyScore(dailyCO2);

  });

  shoppingData.forEach((_, dailyCO2) {
    weeklyScore += EcoScoreCalculator.dailyScore(dailyCO2);

  });

  return weeklyScore;
}


  Future<void> _loadData() async {
    travelEntries = await DBHelper.instance.getAllTravelDiaryEntries();
    wasteEntries = await DBHelper.instance.getAllWasteDiaryEntries();
    eatingEntries = await DBHelper.instance.getAllEatingDiaryEntries();
    shoppingEntries = []; // To be implemented: fetch shopping diary entries

    Map<String, double> newTravelData = {};
    Map<String, double> newWasteData = {};
    Map<String, double> newEatingData = {};
    Map<String, double> newShoppingData = {};
    Map<String, double> oldTravelData = {};
    Map<String, double> oldWasteData = {};
    Map<String, double> oldEatingData = {};
    Map<String, double> oldShoppingData = {};

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
        newWasteData[key] = (newWasteData[key] ?? 0) + entry.carbon;
      } else if (_isInRange(entry.timestamp, _getPreviousViewDate())) {
        final key = _formatKey(entry.timestamp);
        oldWasteData[key] = (oldWasteData[key] ?? 0) + entry.carbon;
      }
    }

    for (var entry in eatingEntries) {
      if (_isInRange(entry.timestamp, _currentViewDate)) {
        final key = _formatKey(entry.timestamp);
        newEatingData[key] = (newEatingData[key] ?? 0) + entry.carbon;
      } else if (_isInRange(entry.timestamp, _getPreviousViewDate())) {
        final key = _formatKey(entry.timestamp);
        oldEatingData[key] = (oldEatingData[key] ?? 0) + entry.carbon;
      }
    }
    
    setState(() {
      travelData = newTravelData;
      wasteData = newWasteData;
      eatingData = newEatingData;
      shoppingData = newShoppingData;
      prevTravelData = oldTravelData;
      prevWasteData = oldWasteData;
      prevEatingData = oldEatingData;
      prevShoppingData = oldShoppingData;
    });


    print('Travel weekly days: ${travelData.length}');
    print('Waste weekly days: ${wasteData.length}');
    print('Eating weekly days: ${eatingData.length}');
    print('Shopping weekly days: ${shoppingData.length}');
    print('Weekly eco score: ${_calculateWeeklyEcoScore()}');
  }

  bool _isInRange(DateTime timestamp, DateTime refDate) {
  // Normalize everything to date-only (no time)
  final ts = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final ref = DateTime(refDate.year, refDate.month, refDate.day);

  late DateTime start;
  late DateTime end;

  switch (_selectedTimeframe) {
    case 'Weekly':
      start = ref.subtract(Duration(days: ref.weekday - 1));
      end = start.add(const Duration(days: 6));
      break;

    case 'Monthly':
      start = DateTime(ref.year, ref.month, 1);
      end = DateTime(ref.year, ref.month + 1, 0);
      break;

    case 'Yearly':
      start = DateTime(ref.year, 1, 1);
      end = DateTime(ref.year, 12, 31);
      break;
  }

  return !ts.isBefore(start) && !ts.isAfter(end);
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
        final week = _weekOfMonth(timestamp);
        return 'Week $week'; // Week 1-5
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
        final totalWeeks = ((lastDay - 1) ~/ 7) + 1;
        return List.generate(totalWeeks, (i) => 'Week ${i + 1}');
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
    final dataMap = _selectedDataType == 'Travel'
    ? travelData
    : _selectedDataType == 'Waste'
        ? wasteData
        : _selectedDataType == 'Eating'
            ? eatingData
            : shoppingData;

    final prevMap = _selectedDataType == 'Travel'
    ? prevTravelData
    : _selectedDataType == 'Waste'
        ? prevWasteData
        : _selectedDataType == 'Eating'
            ? prevEatingData
            : prevShoppingData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Send statistics',
            onPressed: () async {
              await _sendCurrentStatistics();
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(
                  value: _selectedDataType,
                  items: dataTypes,
                  icon: Icons.grid_view,
                  iconBgColor: const Color(0xFF1C8D51),
                  onChanged: (v) {
                    setState(() => _selectedDataType = v);
                    _loadData();
                  },
                ),
                _buildDropdown(
                  value: _selectedTimeframe,
                  items: timeframes,
                  icon: Icons.calendar_month,
                  iconBgColor: const Color(0xFFE9C154),
                  onChanged: (v) {
                    setState(() => _selectedTimeframe = v);
                    _loadData();
                  },
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
            SizedBox(height: 260, child: _buildBarChart(dataMap)),
            const SizedBox(height: 16),
            _buildSummaryCard(dataMap, prevMap),
          ],
        ),
      ),
    );
  }

Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required Color iconBgColor,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color.fromARGB(255, 51, 50, 50)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          items:
              items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 18, color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(e, style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, double> dataMap,
    Map<String, double> prevMap,
  ) {
    if (dataMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No data in this period',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    final avg = total / dataMap.length;
    final maxVal = dataMap.values.reduce(max);
    final minVal = dataMap.values.reduce(min);
    final double totalPercent = 0.0;
    final double avgPercent = -0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bar_chart, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Highlights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _highlightBox(
                title: 'Total emission',
                value: '${total.toStringAsFixed(2)} kg CO2',
                bgColor: const Color(0xFFFFE4CA),
                percent: totalPercent,
              ),
              const SizedBox(width: 12),
              _highlightBox(
                title: 'Average emission',
                value: '${avg.toStringAsFixed(2)} kg CO2',
                bgColor: const Color(0xFFCEE3FF),
                percent: avgPercent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(children: [_minMaxCard(minVal, maxVal)]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _highlightBox({
    required String title,
    required String value,
    required Color bgColor,
    required double percent,
  }) {
    final isPositive = percent >= 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // ⬅ กึ่งกลาง
          children: [
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withOpacity(
                  0.2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percent.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _minMaxCard(double minVal, double maxVal) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6), // shadow เฉพาะด้านล่าง
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFB9F0C1), Color(0xFF53C95C)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Min',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Max',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_valueChip(minVal), _valueChip(maxVal)],
          ),
        ],
      ),
    );
  }

  Widget _valueChip(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${value.toStringAsFixed(2)} kg CO2',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  double _calculateMaxY(Map<String, double> data) {
    if (data.isEmpty) return 1;

    final maxVal = data.values.reduce(max);

    if (maxVal < 0.01) return 0.01;
    if (maxVal < 0.1) return 0.1;
    if (maxVal < 1) return 1;

    return maxVal * 1.2;
  }

  double _calculateYAxisInterval(Map<String, double> data) {
    if (data.isEmpty) return 1;

    final maxVal = data.values.reduce(max);

    if (maxVal < 0.01) return 0.002;
    if (maxVal < 0.1) return 0.02;
    if (maxVal < 1) return 0.2;

    return maxVal / 4;
  }

  Widget _buildBarChart(Map<String, double> dataMap) {
    if (dataMap.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final labels = _generateLabelsForCurrentView();

    final barGroups = List.generate(labels.length, (i) {
      final value = dataMap[labels[i]] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 18,
            color: const Color(0xFF2FB68E), // สีเขียวเต็ม
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    return Stack(
      children: [
        BarChart(
          BarChartData(
            maxY: _calculateMaxY(dataMap),
            barGroups: barGroups,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _calculateYAxisInterval(dataMap),
                  reservedSize: 44,
                  getTitlesWidget: (value, _) {
                    String text;

                    if (value == 0) {
                      text = '0';
                    } else if (value < 0.01) {
                      text = value.toStringAsFixed(4);
                    } else if (value < 0.1) {
                      text = value.toStringAsFixed(3);
                    } else if (value < 1) {
                      text = value.toStringAsFixed(2);
                    } else {
                      text = value.toStringAsFixed(0);
                    }

                    return Text(text, style: const TextStyle(fontSize: 11));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < labels.length) {
                      return Text(
                        labels[idx],
                        style: const TextStyle(fontSize: 11),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}