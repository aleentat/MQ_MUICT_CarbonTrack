class UsageSummary {
  final String userId;
  final String date;
  final int totalLogs;
  final double totalDailyCO2;
  final int ecoScore;

  UsageSummary({
    required this.userId,
    required this.date,
    required this.totalLogs,
    required this.totalDailyCO2,
    required this.ecoScore,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date,
        'totalLogs': totalLogs,
        'totalDailyCO2': totalDailyCO2,
        'ecoScore': ecoScore,
      };
}
