class SyncService {
  /// Attempts to sync unsent daily summaries.
  /// This method should be called only when the app is in foreground.
  static Future<void> tryDailySync() async {
    // Network + battery + user conditions
    if (!await NetworkUtil.canSync()) return;

    final unsyncedDays = await DBHelper.getUnsyncedDays();
    if (unsyncedDays.isEmpty) return;

    for (final day in unsyncedDays) {
      // Aggregate locally (no raw logs sent)
      final summary = await DBHelper.aggregateMetrics(day);

      // Skip days with no activity (green + clean)
      if (!summary.activeToday || summary.totalLogs == 0) {
        await DBHelper.markSynced(day);
        continue;
      }

      final success = await ApiService.sendSummary(summary);

      if (success) {
        await DBHelper.markSynced(day);
      } else {
        // Stop syncing on first failure to avoid repeated network use
        break;
      }
    }
  }
}

