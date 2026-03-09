import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'dart:math';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/usage_summary.dart';
// import '../services/api_service.dart';
// import 'dart:convert';
// import '../utils/eco_score_calculator.dart';

abstract class StatisticPageController extends State<StatisticPage> {
  void showTutorial();
  void checkStatisticTutorial();
}

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  StatisticPageController createState() => StatisticPageState();
}

class StatisticPageState extends StatisticPageController {
  String _selectedDataType = 'Travel';
  String _selectedTimeframe = '1W';
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
  final List<String> timeframes = ['1D', '1W', '1M', '6M', '1Y'];
  List<String> _oneDayTimeLabels() {
    return const ['00:00', '05:00', '10:00', '15:00', '20:00'];
  }

  String _timeBucketLabel(DateTime timestamp) {
    final hour = timestamp.hour;
    if (hour < 5) return '00:00';
    if (hour < 10) return '05:00';
    if (hour < 15) return '10:00';
    if (hour < 20) return '15:00';
    return '20:00';
  }

  GlobalKey activitySelectKey = GlobalKey();
  GlobalKey timeframeSelectKey = GlobalKey();

  late TutorialCoachMark _tutorialCoachMark;
  List<TargetFocus> targets = [];

  void initTutorial() {
    targets = [
      TargetFocus(
        identify: "ActivityType",
        keyTarget: activitySelectKey,
        shape: ShapeLightFocus.RRect,
        radius: 18, 
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Select the type of activity to view its carbon footprint trends.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Timeframe",
        keyTarget: timeframeSelectKey,
        shape: ShapeLightFocus.RRect,
        radius: 18, 
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Choose the time range for the statistics displayed in the chart.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ];
  }

  void showTutorial() {
  initTutorial();
  _tutorialCoachMark = TutorialCoachMark(
    targets: targets,
    textSkip: "SKIP",
    opacityShadow: 0.8,
  );

  _tutorialCoachMark.show(context: context);
}
  
  Future<void> checkStatisticTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seenStatisticTutorial') ?? false;

  if (!seen) {
    showTutorial();
    await prefs.setBool('seenStatisticTutorial', true);
  }
}


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _weekOfMonth(DateTime date) {
    return ((date.day - 1) ~/ 7) + 1;
  }

  Future<void> _loadData() async {
    travelEntries = await DBHelper.instance.getAllTravelDiaryEntries();
    wasteEntries = await DBHelper.instance.getAllWasteDiaryEntries();
    eatingEntries = await DBHelper.instance.getAllEatingDiaryEntries();
    shoppingEntries = await DBHelper.instance.getAllShoppingDiaryEntries();

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

    for (var entry in shoppingEntries) {
      if (_isInRange(entry.timestamp, _currentViewDate)) {
        final key = _formatKey(entry.timestamp);
        newShoppingData[key] = (newShoppingData[key] ?? 0) + entry.carbon;
      } else if (_isInRange(entry.timestamp, _getPreviousViewDate())) {
        final key = _formatKey(entry.timestamp);
        oldShoppingData[key] = (oldShoppingData[key] ?? 0) + entry.carbon;
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
  }

  bool _isInRange(DateTime timestamp, DateTime refDate) {
    final ts = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final ref = DateTime(refDate.year, refDate.month, refDate.day);

    late DateTime start;
    late DateTime end;

    switch (_selectedTimeframe) {
      case '1D':
        start = ref;
        end = ref;
        break;
      case '1W':
        start = ref.subtract(Duration(days: ref.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case '1M':
        start = DateTime(ref.year, ref.month, 1);
        end = DateTime(ref.year, ref.month + 1, 0);
        break;
      case '6M':
        start = DateTime(ref.year, ref.month - 5, 1);
        end = DateTime(ref.year, ref.month + 1, 0);
        break;
      case '1Y':
        start = DateTime(ref.year, 1, 1);
        end = DateTime(ref.year, 12, 31);
        break;
    }

    return !ts.isBefore(start) && !ts.isAfter(end);
  }

  DateTime _getPreviousViewDate() {
    switch (_selectedTimeframe) {
      case '1D':
        return _currentViewDate.subtract(const Duration(days: 1));
      case '1W':
        return _currentViewDate.subtract(const Duration(days: 7));
      case '1M':
        return DateTime(_currentViewDate.year, _currentViewDate.month - 1, 1);
      case '6M':
        return DateTime(_currentViewDate.year, _currentViewDate.month - 6, 1);
      case '1Y':
        return DateTime(_currentViewDate.year - 1, 1, 1);
      default:
        return _currentViewDate;
    }
  }

  void _goToPreviousPeriod() {
    setState(() {
      switch (_selectedTimeframe) {
        case '1D':
          _currentViewDate = _currentViewDate.subtract(const Duration(days: 1));
          break;
        case '1W':
          _currentViewDate = _currentViewDate.subtract(const Duration(days: 7));
          break;
        case '1M':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month - 1,
            1,
          );
          break;
        case '6M':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month - 6,
            1,
          );
          break;
        case '1Y':
          _currentViewDate = DateTime(_currentViewDate.year - 1, 1, 1);
          break;
      }
    });
    _loadData();
  }

  void _goToNextPeriod() {
    setState(() {
      switch (_selectedTimeframe) {
        case '1D':
          _currentViewDate = _currentViewDate.add(const Duration(days: 1));
          break;
        case '1W':
          _currentViewDate = _currentViewDate.add(const Duration(days: 7));
          break;
        case '1M':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month + 1,
            1,
          );
          break;
        case '6M':
          _currentViewDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month + 6,
            1,
          );
          break;
        case '1Y':
          _currentViewDate = DateTime(_currentViewDate.year + 1, 1, 1);
          break;
      }
    });
    _loadData();
  }

  String _formatKey(DateTime timestamp) {
    switch (_selectedTimeframe) {
      case '1D':
        return _timeBucketLabel(timestamp);
      case '1W':
        return DateFormat('E').format(timestamp);
      case '1M':
        final week = _weekOfMonth(timestamp);
        return 'W$week';
      case '6M':
      case '1Y':
        return DateFormat('MMM').format(timestamp);
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
      case '1D':
        start = DateTime(d.year, d.month, d.day);
        end = start;
        break;
      case '1W':
        start = d.subtract(Duration(days: d.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case '1M':
        start = DateTime(d.year, d.month, 1);
        end = DateTime(d.year, d.month + 1, 0);
        break;
      case '6M':
        start = DateTime(d.year, d.month - 5, 1);
        end = DateTime(d.year, d.month + 1, 0);
        break;
      case '1Y':
        start = DateTime(d.year, 1, 1);
        end = DateTime(d.year, 12, 31);
        break;
      default:
        return '';
    }

    String format(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';
    if (_selectedTimeframe == '1D') {
      return '1 Day (${format(start)})';
    }

    return '${format(start)} - ${format(end)}';
  }

  List<String> _generateLabelsForCurrentView() {
    switch (_selectedTimeframe) {
      case '1D':
        return _oneDayTimeLabels();
      case '1W':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case '1M':
        final lastDay =
            DateTime(_currentViewDate.year, _currentViewDate.month + 1, 0).day;
        final totalWeeks = ((lastDay - 1) ~/ 7) + 1;
        return List.generate(totalWeeks, (i) => 'W${i + 1}');
      case '6M':
        return List.generate(6, (i) {
          final monthDate = DateTime(
            _currentViewDate.year,
            _currentViewDate.month - 5 + i,
            1,
          );
          return DateFormat('MMM').format(monthDate);
        });
      case '1Y':
        return List.generate(
          12,
          (i) => DateFormat('MMM').format(DateTime(0, i + 1)),
        );
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataMap =
        _selectedDataType == 'Travel'
            ? travelData
            : _selectedDataType == 'Waste'
            ? wasteData
            : _selectedDataType == 'Eating'
            ? eatingData
            : shoppingData;

    final prevMap =
        _selectedDataType == 'Travel'
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
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: ListView(
          children: [
            _buildSegmentSlider(
              key: activitySelectKey,
              value: _selectedDataType,
              items: dataTypes,
              onChanged: (v) {
                setState(() => _selectedDataType = v);
                _loadData();
              },
            ),
            const SizedBox(height: 10),
            _buildSegmentSlider(
              key: timeframeSelectKey,
              value: _selectedTimeframe,
              items: timeframes,
              onChanged: (v) {
                setState(() => _selectedTimeframe = v);
                _loadData();
              },
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
            SizedBox(height: 260, child: _buildLineChart(dataMap)),
            const SizedBox(height: 16),
            _buildSummaryCard(dataMap, prevMap),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSlider({
    Key? key,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children:
            items.map((item) {
              final isSelected = item == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color.fromARGB(255, 41, 132, 127)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      item,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
    final prevTotal = prevMap.values.fold(0.0, (a, b) => a + b);
    final prevAvg = prevMap.isEmpty ? 0.0 : prevTotal / prevMap.length;

    final double totalPercent = _calculatePercentChange(total, prevTotal);
    final double avgPercent = _calculatePercentChange(avg, prevAvg);
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

  double _calculatePercentChange(double current, double previous) {
    if (previous == 0) {
      if (current == 0) return 0;
      return 100;
    }
    return ((current - previous) / previous) * 100;
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

  Widget _buildLineChart(Map<String, double> dataMap) {
    if (dataMap.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final labels = _generateLabelsForCurrentView();
    final spots = List.generate(labels.length, (i) {
      final value = dataMap[labels[i]] ?? 0;
      return FlSpot(i.toDouble(), value);
    });

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(dataMap),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: const Color(0xFF2FB68E),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2FB68E).withOpacity(0.18),
            ),
          ),
        ],
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
    interval: 1,
    getTitlesWidget: (value, meta) {
      if (value % 1 != 0) {
        return const SizedBox.shrink();
      }

      final idx = value.toInt();
      if (idx < 0 || idx >= labels.length) {
        return const SizedBox.shrink();
      }

      final step =
          labels.length <= 6 ? 1 : (labels.length <= 12 ? 2 : 3);
      final isLast = idx == labels.length - 1;

      if (!isLast && idx % step != 0) {
        return const SizedBox.shrink();
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 6,
        child: Text(
          labels[idx],
          style: const TextStyle(fontSize: 10),
        ),
      );
    },
  ),
),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
