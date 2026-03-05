class EatingDiaryEntry {
  final String name;
  final String? variant;    // Beef / Chicken / Fish / Pork
  final DateTime timestamp;
  final int quantity;
  final String? note;
  final double carbon;

  EatingDiaryEntry({
    required this.name,
    this.variant,
    required this.timestamp,
    this.quantity = 1,
    this.note = '',
    required this.carbon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'variant': variant,
      'timestamp': timestamp.toIso8601String(),
      'quantity': quantity,
      'note': note,
      'carbon': carbon,
    };
  }

  factory EatingDiaryEntry.fromMap(Map<String, dynamic> map) {
    return EatingDiaryEntry(
      name: map['name'],
      variant: map['variant'],
      timestamp: DateTime.parse(map['timestamp']),
      quantity: map['quantity'],
      note: map['note'],
      carbon: map['carbon'],
    );
  }
}