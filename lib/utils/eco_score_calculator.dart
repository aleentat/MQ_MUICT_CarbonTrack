class EcoScoreCalculator {
  static int dailyScore(double co2) {
    if (co2 >= 20.494) return -2;
    if (co2 >= 11.784) return -1;
    if (co2 >= 8.701) return 0;
    if (co2 >= 5.124) return 1;
    if (co2 > 0) return 2;
    return 0;
  }
}
