enum TreeStage { sprout, healthy, blooming }

class WeeklyEcoState {
  final int weekIndex;
  final double avgScore;

  WeeklyEcoState({
    required this.weekIndex,
    required this.avgScore,
  });

  TreeStage get stage {
    if (avgScore >= 6) return TreeStage.blooming;
    if (avgScore >= 4) return TreeStage.healthy;
    return TreeStage.sprout;
  }
}
