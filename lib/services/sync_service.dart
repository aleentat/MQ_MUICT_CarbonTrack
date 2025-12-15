class SyncService {
  static Future<void> tryDailySync() async {
    if (!await NetworkUtil.canSync()) return;

    final days = await DBHelper.getUnsyncedDays();
    for (final day in days) {
      final summary = await DBHelper.aggregateMetrics(day);
      final success = await ApiService.sendSummary(summary);
      if (success) {
        await DBHelper.markSynced(day);
      }
    }
  }
}
