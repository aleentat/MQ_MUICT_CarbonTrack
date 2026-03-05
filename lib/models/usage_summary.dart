class UsageSummary {
  final String userId;
  final int age;
  final String date;
  final int totalLogs;
  final int appOpens;
  final Map<String, double> co2Breakdown;
  final double totalDailyCO2;
  final int ecoScore;

  UsageSummary({
    required this.userId,
    required this.age,
    required this.date,
    required this.totalLogs,
    required this.appOpens,
    required this.co2Breakdown,
    required this.totalDailyCO2,
    required this.ecoScore,
  });

  Map<String, dynamic> toJson() => {
  'userId': userId,
  'age': age,
  'date': date,
  'totalLogs': totalLogs,
  'appOpens': appOpens,
  'co2Breakdown': {
    'travel': co2Breakdown['travel'],
    'waste': co2Breakdown['waste'],
    'eating': co2Breakdown['eating'],
    'shopping': co2Breakdown['shopping'],
  },
  'totalDailyCO2': totalDailyCO2,
  'ecoScore': ecoScore,
};
}
