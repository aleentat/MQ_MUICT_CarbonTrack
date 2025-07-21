class WasteDiaryEntry {
  final String name;
  final String type; // Compost / Recyclable / Trash
  final DateTime timestamp;
  final int quantity;
  final String? note;  
  final String? imagePath;

  WasteDiaryEntry({
    required this.name,
    required this.type,
    required this.timestamp,
    this.quantity = 1,
    this.note = '',
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'quantity': quantity,
      'note': note,
      'imagePath': imagePath,
    };
  }

  factory WasteDiaryEntry.fromMap(Map<String, dynamic> map) {
    return WasteDiaryEntry(
      name: map['name'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      quantity: map['quantity'],
      note: map['note'],
      imagePath: map['imagePath'],
    );
  }
}
