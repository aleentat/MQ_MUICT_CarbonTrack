import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../database/db_helper.dart';
import 'carbon_diary_page.dart';
import 'statistic_page.dart';
import 'activity_page.dart';
import '../widgets/home_tree_widget.dart';
import '../models/weekly_eco_state.dart';
import '../utils/eco_score_calculator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double _totalTravelCarbon = 0.0;
  int _weeklyEcoScore = 0;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  final travelEntries =
      await DBHelper.instance.getAllTravelDiaryEntries();

  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day)
    .subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  double total = 0.0;

  for (final entry in travelEntries) {
    final d = DateTime(
      entry.timestamp.year,
      entry.timestamp.month,
      entry.timestamp.day,
    );

    if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
      total += entry.carbon;
    }
  }

  final score = await _calculateWeeklyEcoScore();

  setState(() {
    _weeklyEcoScore = score;
  });
}

Future<int> _calculateWeeklyEcoScore() async {
  final travelEntries =
      await DBHelper.instance.getAllTravelDiaryEntries();
  final wasteEntries =
      await DBHelper.instance.getAllWasteDiaryEntries();

  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  final Map<String, double> dailyTotals = {};

  void addEntry(DateTime timestamp, double carbon) {
    final d = DateTime(timestamp.year, timestamp.month, timestamp.day);
    if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
      final key = DateFormat('E').format(d); // Mon–Sun (same as StatisticPage)
      dailyTotals[key] = (dailyTotals[key] ?? 0) + carbon;
    }
  }

  for (final e in travelEntries) {
    addEntry(e.timestamp, e.carbon);
  }

  for (final e in wasteEntries) {
    addEntry(e.timestamp, e.carbon);
  }

  int weeklyScore = 0;
  dailyTotals.forEach((day, dailyCO2) {
    weeklyScore += EcoScoreCalculator.dailyScore(dailyCO2);
  });

  print('HOME weekly eco score: $weeklyScore');
  print('Daily totals: $dailyTotals');

  return weeklyScore;
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, String>> mockNews = [
    {
      "title": "Thailand sets goal to cut CO₂ emissions by 30% by 2030",
      "summary":
          "The government introduces a Net Zero policy for national sustainability.",
      "image": "assets/images/news1.jpeg",
      "url": "https://thailand.go.th/issue-focus-detail/--ndc--2573",
    },
    {
      "title": "New technology captures carbon directly from air",
      "summary":
          "Scientists develop Direct Air Capture (DAC) to fight climate change.",
      "image": "assets/images/news2.jpeg",
      "url":
          "https://phys.org/news/2025-06-ai-materials-capture-air.html#:~:text=In%20order%20to%20help%20prevent,the%20air—is%20gaining%20attention.",
    },
  ];

  final List<Map<String, dynamic>> ecoTips = [
    {
      'icon': Icons.directions_bike,
      'title': 'Bike More',
      'description': 'Reduce car use by biking to nearby places.',
    },
    {
      'icon': Icons.lightbulb,
      'title': 'Save Energy',
      'description': 'Switch off lights when not in use.',
    },
    {
      'icon': Icons.recycling,
      'title': 'Recycle',
      'description': 'Separate and recycle your daily waste.',
    },
    {
      'icon': Icons.water_drop,
      'title': 'Save Water',
      'description': 'Fix leaking taps and use water wisely.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 155, 255, 242),
            Color.fromARGB(255, 183, 255, 236),
            Color.fromARGB(255, 230, 252, 252),
            Color(0xFFFDFDFD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // title: Text(
          //   'Carbon Diary',
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
          ],
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: IndexedStack(
            key: ValueKey<int>(_selectedIndex),
            index: _selectedIndex,
            children: [
              _buildHomeContent(),
              ActivityPage(),
              CarbonDiaryPage(),
              StatisticPage(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 10),
          _buildEcoScoreBar(),
          const SizedBox(height: 6),
          _buildCarbonTipBubble(),
          const SizedBox(height: 40),
          _buildTipsSection(ecoTips),
          const SizedBox(height: 40),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your daily carbon footprint and help save the planet together',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset('assets/gif/earth.gif', height: 150),
            // child: Lottie.asset(
            //   'assets/lottie/earth.json',
            //   height: 100,
            //   repeat: true,
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoScoreBar() {
  final int weeklyEcoScore = _weeklyEcoScore;

  TreeStage treeStage;
  if (weeklyEcoScore >= 6) {
    treeStage = TreeStage.blooming;
  } else if (weeklyEcoScore >= 4) {
    treeStage = TreeStage.healthy;
  } else {
    treeStage = TreeStage.sprout;
  }

  // Week range display
  DateTime now = DateTime.now();
  DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
  DateTime weekEnd = weekStart.add(const Duration(days: 6));
  String weekRange =
      '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM yyyy').format(weekEnd)}';

  // Progress bar value (eco-score based)
  final double maxScore = 7.0;
  final double progressValue =
      (weeklyEcoScore / maxScore).clamp(0.0, 1.0);

  return Container(
    padding: const EdgeInsets.all(23),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Title row
        Row(
          children: [
            Text(
              'Weekly Eco Score',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($weekRange)',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            HomeTreeWidget(stage: treeStage),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 14,
                        backgroundColor: Colors.transparent,
                        color: _treeColor(treeStage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Score: $weeklyEcoScore • ${_treeLabel(treeStage)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  Color _treeColor(TreeStage stage) {
    switch (stage) {
      case TreeStage.sprout:
        return Colors.brown;
      case TreeStage.healthy:
        return Colors.green;
      case TreeStage.blooming:
        return Colors.lightGreen;
    }
  }
  String _treeLabel(TreeStage stage) {
    switch (stage) {
      case TreeStage.sprout:
        return 'Sprout';
      case TreeStage.healthy:
        return 'Healthy';
      case TreeStage.blooming:
        return 'Blooming';
    }
  }

  Widget _buildCarbonTipBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 29, 71, 62),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Did you know?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 163, 225, 226),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Keeping your weekly travel emissions under 20kg of CO₂ is a great way to care for the planet ! ",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            left: 58,
            top: 0,
            child: CustomPaint(painter: TrianglePainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(List<Map<String, dynamic>> ecoTips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eco Tips',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ecoTips.length,
            itemBuilder: (context, index) {
              final tip = ecoTips[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 253, 236),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 210, 237, 211),
                      child: Icon(tip['icon'], color: Colors.green[800]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tip['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip['description'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environmental News',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(children: mockNews.map(_buildNewsCard).toList()),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, String> news) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200, width: 1),
      ),
      color: const Color(0xFFF5FFF8), 
      elevation: 3,
      shadowColor: Colors.green.shade100,
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(news['url'] ?? '');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                news['image']!,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news['summary']!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 13),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ConvexAppBar(
      style: TabStyle.reactCircle,
      backgroundColor: Colors.white,
      activeColor: Color.fromARGB(255, 96, 176, 158),
      color: Colors.grey[600],
      items: [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.local_activity, title: 'Activity'),
        TabItem(icon: Icons.book, title: 'Diary'),
        TabItem(icon: Icons.bar_chart, title: 'Stats'),
      ],
      initialActiveIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color.fromARGB(255, 29, 71, 62)
          ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 12);
    path.lineTo(10, 0);
    path.lineTo(20, 12);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
