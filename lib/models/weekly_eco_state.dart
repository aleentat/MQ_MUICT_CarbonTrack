enum TreeStage { dry, seed, sprout, healthy, blooming }

class WeeklyEcoState {
  final int weekIndex;
  final double avgScore;

  WeeklyEcoState({
    required this.weekIndex,
    required this.avgScore,
  });

  TreeStage get stage {
    if (avgScore >= 7) return TreeStage.blooming;
    if (avgScore >= 5) return TreeStage.healthy;
    if (avgScore >= 3) return TreeStage.sprout;
    if (avgScore >= 1) return TreeStage.seed;
    return TreeStage.dry;
  }
}
