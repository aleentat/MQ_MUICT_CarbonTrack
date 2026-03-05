import '../database/db_helper.dart';
import '../models/usage_summary.dart';
import '../services/api_service.dart';
import '../utils/eco_score_calculator.dart';

class StatisticService {
  static Future<void> sendTodaySummary() async {
    final db = DBHelper.instance;

    final travel = await db.getAllTravelDiaryEntries();
    final waste = await db.getAllWasteDiaryEntries();
    final eating = await db.getAllEatingDiaryEntries();
    final shopping = await db.getAllShoppingDiaryEntries();

    final travelCO2 =
        travel.fold<double>(0, (s, e) => s + e.carbon);
    final wasteCO2 =
        waste.fold<double>(0, (s, e) => s + e.carbon);
    final eatingCO2 =
        eating.fold<double>(0, (s, e) => s + e.carbon);
    final shoppingCO2 =
        shopping.fold<double>(0, (s, e) => s + e.carbon);

    final totalLogs =
        travel.length + waste.length + eating.length + shopping.length;

    final totalDailyCO2 =
        travelCO2 + wasteCO2 + eatingCO2 + shoppingCO2;

    final user = await db.getUserProfile();
    final username = await db.getOrCreateUsername();

    final summary = UsageSummary(
      userId: username,
      age: user?['age'] ?? 0,
      date: DateTime.now().toIso8601String().split('T').first,
      totalLogs: totalLogs,
      appOpens: await db.getTodayAppOpenCount(),
      co2Breakdown: {
        'travel': travelCO2,
        'waste': wasteCO2,
        'eating': eatingCO2,
        'shopping': shoppingCO2,
      },
      totalDailyCO2: totalDailyCO2,
      ecoScore: EcoScoreCalculator.dailyScore(totalDailyCO2),
    );

    await ApiService.sendSummary(summary);
  }
}