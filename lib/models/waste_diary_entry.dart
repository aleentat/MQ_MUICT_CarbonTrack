class WasteDiaryEntry {
  final int? id;
  final String name;
  final String type; // Compost / Recyclable / Trash
  final DateTime timestamp;

  WasteDiaryEntry({
    this.id,
    required this.name,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WasteDiaryEntry.fromMap(Map<String, dynamic> map) {
    return WasteDiaryEntry(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
