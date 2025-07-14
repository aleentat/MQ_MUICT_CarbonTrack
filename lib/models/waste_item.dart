class WasteItem {
  final int? id;
  final String name;
  final String type;
  final String category;

  WasteItem({
    this.id,
    required this.name,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
    };
  }

  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      category: map['category'],
    );
  }
}