import 'package:flutter/material.dart';
import '../models/weekly_eco_state.dart';

class GamificationPage extends StatefulWidget {
  final List<int> weeklyEcoScores;
  final List<List<double>> weeklyDailyCarbon;
  final List<List<int>> weeklyDailyScores;

  const GamificationPage({
    super.key,
    required this.weeklyEcoScores,
    required this.weeklyDailyCarbon,
    required this.weeklyDailyScores,
  });

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  int? selectedWeek;

  TreeStage _stageFromScore(int score) {
    if (score >= 7) return TreeStage.blooming;
    if (score >= 5) return TreeStage.healthy;
    if (score >= 3) return TreeStage.sprout;
    if (score >= 1) return TreeStage.seed;
    return TreeStage.dry;
  }

  String _treeAsset(TreeStage stage) {
    switch (stage) {
      case TreeStage.dry:
        return 'assets/images/trees/drytree.png';
      case TreeStage.seed:
        return 'assets/images/trees/seed.png';
      case TreeStage.sprout:
        return 'assets/images/trees/sprout.png';
      case TreeStage.healthy:
        return 'assets/images/trees/tree.png';
      case TreeStage.blooming:
        return 'assets/images/trees/blooming.png';
    }
  }

  @override
  void initState() {
    super.initState();

    // Determine current week of month
    final now = DateTime.now();
    final weekIndex = ((now.day - 1) ~/ 7);

    if (widget.weeklyEcoScores.isNotEmpty) {
      selectedWeek = weekIndex.clamp(0, widget.weeklyEcoScores.length - 1);
    }
  }

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text(
            'Gamification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildIsometricForest(widget.weeklyEcoScores),
              const SizedBox(height: 25),
              if (selectedWeek != null) _buildWeeklyDetail(selectedWeek!),
            ],
          ),
        ),
      ),
    );
  }

  // 2x2 Forest Grid
  Widget _buildIsometricForest(List<int> weeklyScores) {
    int weekCount = widget.weeklyEcoScores.length;

    const double tileWidth = 120;
    const double xOffset = 60;
    const double yOffset = 40;

    final positions = [
      const Offset(xOffset, 0), // Week 1
      const Offset(xOffset * 2, yOffset), // Week 2
      const Offset(0, yOffset), // Week 3
      const Offset(xOffset, yOffset * 2), // Week 4
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text(
            'Your Monthly Forest',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 20),
          SizedBox(
            width: 320,
            height: 280,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..translate(35.0, 50.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // LAND
                  for (int i = 0; i < weekCount; i++)
                    Positioned(
                      left: positions[i].dx,
                      top: positions[i].dy,
                      child: Image.asset(
                        'assets/images/land.png',
                        width: tileWidth,
                      ),
                    ),

                  // TREE
                  for (int i = 0; i < weekCount; i++)
                    Positioned(
                      left: positions[i].dx + tileWidth / 4,
                      top: positions[i].dy - 20,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeek = i;
                          });
                        },
                        child: Image.asset(
                          _treeAsset(_stageFromScore(weeklyScores[i])),
                          width: 65,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedWeek != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Week ${selectedWeek! + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDetail(int index) {
    if (widget.weeklyEcoScores.isEmpty ||
        widget.weeklyDailyCarbon.isEmpty ||
        widget.weeklyDailyScores.isEmpty ||
        index >= widget.weeklyEcoScores.length ||
        index >= widget.weeklyDailyCarbon.length ||
        index >= widget.weeklyDailyScores.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No data available for this week 🌱",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final weeklyScore = widget.weeklyEcoScores[index];
    final dailyCarbon = widget.weeklyDailyCarbon[index];
    final dailyScores = widget.weeklyDailyScores[index];

    const List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Score Title
          Text(
            "Week ${index + 1} Summary",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "Total Weekly Score: $weeklyScore",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Daily Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Daily List
          Column(
            children: List.generate(7, (i) {
              final carbon = i < dailyCarbon.length ? dailyCarbon[i] : 0.0;
              final score = i < dailyScores.length ? dailyScores[i] : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      days[i],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${carbon.toStringAsFixed(2)} kg CO₂",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Score: $score",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    );
  }
}
