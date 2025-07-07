class CarbonLogEntry {
  final String type; // 'travel' or 'waste'
  final String description;
  final DateTime timestamp;

  CarbonLogEntry({
    required this.type,
    required this.description,
    required this.timestamp,
  });
}
