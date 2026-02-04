import 'package:flutter/material.dart';
import '../models/weekly_eco_state.dart';

class GamificationPage extends StatelessWidget {
  final List<int> weeklyEcoScores; // 4 weeks

  const GamificationPage({super.key, required this.weeklyEcoScores});

  TreeStage _stageFromScore(int score) {
    if (score >= 6) return TreeStage.blooming;
    if (score >= 4) return TreeStage.healthy;
    return TreeStage.sprout;
  }

  String _treeAsset(TreeStage stage) {
    switch (stage) {
      case TreeStage.sprout:
        return 'assets/images/tree.png';
      case TreeStage.healthy:
        return 'assets/images/tree.png';
      case TreeStage.blooming:
        return 'assets/images/tree.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double averageScore =
        weeklyEcoScores.reduce((a, b) => a + b) / weeklyEcoScores.length;

    final double progress = (averageScore / 7).clamp(0.0, 1.0);

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
          title: Text(
            'Gamification',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildIsometricForest(weeklyEcoScores),
              const SizedBox(height: 25),
              _buildMonthlySummary(averageScore, progress),
            ],
          ),
        ),
      ),
    );
  }

  // 🌳 2x2 Forest Grid
  Widget _buildIsometricForest(List<int> weeklyScores) {
    const double tileWidth = 120;
    const double tileHeight = 80;
    const double xOffset = 60;
    const double yOffset = 40;

    final positions = [
      Offset(xOffset, 0), // Week 1
      Offset(xOffset * 2, yOffset), // Week 2
      Offset(0, yOffset), // Week 3
      Offset(xOffset, yOffset * 2), // Week 4
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            'Your Monthly Forest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 320,
            height: 280,
            child: Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..translate(35.0, 50.0), 
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🌍 LAND
                  for (int i = 0; i < 4; i++)
                    Positioned(
                      left: positions[i].dx,
                      top: positions[i].dy,
                      child: Image.asset(
                        'assets/images/land.png',
                        width: tileWidth,
                      ),
                    ),
                  // 🌳 TREE
                  for (int i = 0; i < 4; i++)
                    Positioned(
                      left: positions[i].dx + tileWidth / 4,
                      top: positions[i].dy - 20,
                      child: Image.asset(
                        _treeAsset(_stageFromScore(weeklyScores[i])),
                        width: 60,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandWithTree(TreeStage stage, int weekIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(_treeAsset(stage), height: 80),
        const SizedBox(height: 4),
        Image.asset('assets/images/land.png', height: 40),
        const SizedBox(height: 6),
        Text('Week ${weekIndex + 1}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 📊 Monthly Summary (ภาพรวม)
  Widget _buildMonthlySummary(double averageScore, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Eco Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF44765F),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _buildStatBox(
                title: 'Avg Eco Score',
                value: averageScore.toStringAsFixed(1),
                icon: Icons.eco,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                title: 'Weeks Logged',
                value: weeklyEcoScores.length.toString(),
                icon: Icons.calendar_month,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 255, 248),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF44765F)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
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
