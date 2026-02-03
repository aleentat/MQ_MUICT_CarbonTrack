class ShoppingDiaryEntry {
  final String name;
  final String type;
  final DateTime timestamp;
  final int quantity;
  final String? note;
  final double carbon;
  final double unit; 

  ShoppingDiaryEntry({
    required this.name,
    required this.type,
    required this.timestamp,
    this.quantity = 1,
    this.note = '',
    required this.carbon,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'quantity': quantity,
      'note': note,
      'carbon': carbon,
      'unit': unit,
    };
  }

  factory ShoppingDiaryEntry.fromMap(Map<String, dynamic> map) {
    return ShoppingDiaryEntry(
      name: map['name'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      quantity: map['quantity'],
      note: map['note'],
      carbon: map['carbon'],
      unit: map['unit'],
    );
  }
}