import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../database/db_helper.dart';
import 'carbon_diary_page.dart';
import 'statistic_page.dart';
import 'activity_page.dart';
import 'gamification_page.dart';
import '../widgets/home_tree_widget.dart';
import '../models/weekly_eco_state.dart';
import '../utils/eco_score_calculator.dart';
import 'user_profile_page.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _weeklyEcoScore = 0;
  final GlobalKey<ActivityPageController> activityPageKey = GlobalKey();
  final GlobalKey<CarbonDiaryPageController> diaryPageKey = GlobalKey();
  final GlobalKey<StatisticPageController> statsPageKey = GlobalKey();

  GlobalKey forestButtonKey = GlobalKey();
  GlobalKey activityButtonKey = GlobalKey();
  GlobalKey diaryButtonKey = GlobalKey();
  GlobalKey statsButtonKey = GlobalKey();
  GlobalKey profileButtonKey = GlobalKey();
  GlobalKey infoButtonKey = GlobalKey();
  GlobalKey refreshButtonKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  void initTutorial() {
    targets = [
      TargetFocus(
        identify: "Profile",
        keyTarget: profileButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Tap here to view or edit your profile.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Info",
        keyTarget: infoButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Tap here to view app tutorials anytime.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Refresh",
        keyTarget: refreshButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Refresh your latest eco score data.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Forest",
        keyTarget: forestButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Visit your forest to see how your eco score grows your trees!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Activity",
        keyTarget: activityButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Add daily your activities here.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Diary",
        keyTarget: diaryButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "View your activities in the diary.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),

      TargetFocus(
        identify: "Stats",
        keyTarget: statsButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "View charts and track your carbon progress.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ];
  }

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      opacityShadow: 0.8,
    );

    tutorialCoachMark.show(context: context);
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool seenTutorial = prefs.getBool('seenTutorial') ?? false;

    if (!seenTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initTutorial();
        showTutorial();
      });

      await prefs.setBool('seenTutorial', true);
    }
  }

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadData();
    await _checkTutorial();
  }

  List<int> _monthlyWeeklyScores = [0, 0, 0, 0];
  List<List<double>> _weeklyDailyCarbon = [];
  List<List<int>> _weeklyDailyScores = [];

  Future<void> _loadData() async {
    final score = await _calculateWeeklyEcoScore();
    final monthlyScores = await _calculateMonthlyWeeklyScores();

    setState(() {
      _weeklyEcoScore = score;
      _monthlyWeeklyScores = monthlyScores;
    });
  }

  Future<int> _calculateWeeklyEcoScore() async {
    final travelEntries = await DBHelper.instance.getAllTravelDiaryEntries();
    final wasteEntries = await DBHelper.instance.getAllWasteDiaryEntries();
    final foodEntries = await DBHelper.instance.getAllEatingDiaryEntries();
    final shoppingEntries =
        await DBHelper.instance.getAllShoppingDiaryEntries();

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final Map<String, double> dailyTotals = {};

    void addEntry(DateTime timestamp, double carbon) {
      final d = DateTime(timestamp.year, timestamp.month, timestamp.day);
      if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
        final key = DateFormat(
          'E',
        ).format(d); // Mon–Sun (same as StatisticPage)
        dailyTotals[key] = (dailyTotals[key] ?? 0) + carbon;
      }
    }

    for (final e in travelEntries) {
      addEntry(e.timestamp, e.carbon);
    }

    for (final e in wasteEntries) {
      addEntry(e.timestamp, e.carbon);
    }

    for (final e in foodEntries) {
      addEntry(e.timestamp, e.carbon);
    }

    for (final e in shoppingEntries) {
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

  Future<List<int>> _calculateMonthlyWeeklyScores() async {
    final travelEntries = await DBHelper.instance.getAllTravelDiaryEntries();
    final wasteEntries = await DBHelper.instance.getAllWasteDiaryEntries();
    final foodEntries = await DBHelper.instance.getAllEatingDiaryEntries();
    final shoppingEntries =
        await DBHelper.instance.getAllShoppingDiaryEntries();

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    List<int> weeklyScores = [];
    List<List<double>> weeklyCarbonData = [];
    List<List<int>> weeklyScoreData = [];

    // Loop 4 weeks
    for (int week = 0; week < 4; week++) {
      DateTime weekStart = firstDayOfMonth.add(Duration(days: week * 7));
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      Map<int, double> dailyCarbon = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

      void addEntry(DateTime timestamp, double carbon) {
        final d = DateTime(timestamp.year, timestamp.month, timestamp.day);

        if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
          dailyCarbon[d.weekday] = (dailyCarbon[d.weekday] ?? 0) + carbon;
        }
      }

      for (final e in travelEntries) {
        addEntry(e.timestamp, e.carbon);
      }

      for (final e in wasteEntries) {
        addEntry(e.timestamp, e.carbon);
      }

      for (final e in foodEntries) {
        addEntry(e.timestamp, e.carbon);
      }

      for (final e in shoppingEntries) {
        addEntry(e.timestamp, e.carbon);
      }

      int weeklyScore = 0;
      List<double> dailyCarbonList = [];
      List<int> dailyScoreList = [];

      for (int i = 1; i <= 7; i++) {
        double carbon = dailyCarbon[i] ?? 0;
        int score = EcoScoreCalculator.dailyScore(carbon);

        dailyCarbonList.add(carbon);
        dailyScoreList.add(score);
        weeklyScore += score;
      }

      weeklyScores.add(weeklyScore);
      weeklyCarbonData.add(dailyCarbonList);
      weeklyScoreData.add(dailyScoreList);
    }

    setState(() {
      _monthlyWeeklyScores = weeklyScores;
      _weeklyDailyCarbon = weeklyCarbonData;
      _weeklyDailyScores = weeklyScoreData;
    });

    return weeklyScores;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Future.delayed(Duration(milliseconds: 300), () {
        activityPageKey.currentState?.checkActivityTutorial();
      });
    }
    if (index == 2) {
      Future.delayed(Duration(milliseconds: 300), () {
        diaryPageKey.currentState?.checkDiaryTutorial();
        diaryPageKey.currentState?.refresh();
      });
    }
    if (index == 3) {
      Future.delayed(Duration(milliseconds: 300), () {
        statsPageKey.currentState?.checkStatisticTutorial();
      });
    }
  }

  final List<Map<String, String>> mockNews = [
    {
      "title": "How much CO₂ does Thailand emit per person?",
      "summary": "From Our World in Data",
      "image": "assets/images/news1.jpeg",
      "url": "https://ourworldindata.org/profile/co2/thailand",
    },
    {
      "title": "GHG have increased global temperatures",
      "summary": "From Our World in Data",
      "image": "assets/images/news2.jpg",
      "url": "https://ourworldindata.org/co2-and-greenhouse-gas-emissions",
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
            Color(0xFF9BFFF2),
            Color(0xFFB7FFEC),
            Color(0xFFE6FCFC),
            Color(0xFFFDFDFD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              key: profileButtonKey,
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                );
              },
            ),
            IconButton(
              key: infoButtonKey,
              icon: Icon(Icons.info_outline),
              onPressed: () {
                switch (_selectedIndex) {
                  case 0:
                    initTutorial();
                    showTutorial();
                    break;

                  case 1:
                    activityPageKey.currentState?.showTutorial();
                    break;
                  case 2:
                    diaryPageKey.currentState?.showTutorial();
                    break;
                  case 3:
                    statsPageKey.currentState?.showTutorial();
                    break;
                }
              },
            ),
            IconButton(
              key: refreshButtonKey,
              icon: Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            ActivityPage(key: activityPageKey),
            CarbonDiaryPage(key: diaryPageKey),
            StatisticPage(key: statsPageKey),
          ],
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEcoScoreBar() {
    final int weeklyEcoScore = _weeklyEcoScore;

    TreeStage treeStage;
    if (weeklyEcoScore >= 7) {
      treeStage = TreeStage.blooming;
    } else if (weeklyEcoScore >= 5) {
      treeStage = TreeStage.healthy;
    } else if (weeklyEcoScore >= 3) {
      treeStage = TreeStage.sprout;
    } else if (weeklyEcoScore >= 1) {
      treeStage = TreeStage.seed;
    } else {
      treeStage = TreeStage.dry;
    }

    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    DateTime weekEnd = weekStart.add(const Duration(days: 6));
    String weekRange =
        '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM yyyy').format(weekEnd)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 380;
        final double scoreFontSize = isNarrow ? 24 : 30;
        final double labelFontSize = isNarrow ? 18 : 22;
        final double treeSize = isNarrow ? 74 : 90;

        return Container(
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 25 : 45,
            30,
            isNarrow ? 25 : 45,
            30,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Weekly Eco Score',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                weekRange,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            const Icon(Icons.stars_rounded, size: 30),
                            Text(
                              '$weeklyEcoScore',
                              style: TextStyle(
                                fontSize: scoreFontSize,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            Text(
                              'Score',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          key: forestButtonKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19AC98),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 14 : 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () async {
                            await _loadData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => GamificationPage(
                                      weeklyEcoScores: _monthlyWeeklyScores,
                                      weeklyDailyCarbon: _weeklyDailyCarbon,
                                      weeklyDailyScores: _weeklyDailyScores,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forest_rounded, size: 30),
                          label: Text(
                            'My Forest',
                            style: TextStyle(
                              fontSize: isNarrow ? 15 : 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: isNarrow ? 90 : 110),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HomeTreeWidget(stage: treeStage, size: treeSize),
                        const SizedBox(height: 2),
                        Text(
                          _treeLabel(treeStage),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isNarrow ? 18 : 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _treeLabel(TreeStage stage) {
    switch (stage) {
      case TreeStage.dry:
        return 'Dry';
      case TreeStage.seed:
        return 'Seed';
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
              color: Color(0xFF00534b),
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
                  "The average person in Thailand produces about 10.24 kg of CO₂e every day ! ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 227, 242, 242),
                      child: Icon(tip['icon'], color: Color(0xFF19AC98)),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(children: mockNews.map(_buildNewsCard).toList()),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, String> news) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 3,
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
                height: 100,
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
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news['summary']!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                color: Color(0xFF4b635f),
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
      activeColor: Color(0xFF19AC98),
      color: Colors.grey[600],
      items: [
        TabItem(icon: Icon(Icons.home), title: 'Home'),
        TabItem(
          icon: Container(
            key: activityButtonKey,
            child: Icon(Icons.local_activity),
          ),
          title: 'Activity',
        ),
        TabItem(
          icon: Container(key: diaryButtonKey, child: Icon(Icons.book)),
          title: 'Diary',
        ),
        TabItem(
          icon: Container(key: statsButtonKey, child: Icon(Icons.bar_chart)),
          title: 'Stats',
        ),
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
          ..color = Color(0xFF00534b)
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
