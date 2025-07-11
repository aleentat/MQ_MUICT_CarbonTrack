class WasteItem {
  final int? id;
  final String name;
  final String type; // Compost / Recyclable / Trash

  WasteItem({this.id, required this.name, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}