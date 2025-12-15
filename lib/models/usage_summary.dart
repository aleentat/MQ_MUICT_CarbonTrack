class UsageSummary {
  final String userId;
  final String date;
  final int totalLogs;
  final double avgDailyCO2;
  final int ecoScore;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date,
    'totalLogs': totalLogs,
    'avgDailyCO2': avgDailyCO2,
    'ecoScore': ecoScore,
  };
}