class WasteItem {
  final int id;
  final String name;
  final String type;
  final String category;
  final String subcategory;
  final String tip;
  final String iconPath;
  final double ef; // kgCO2e per ton
  final double unit; // kg per item

  WasteItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.subcategory,
    required this.tip,
    required this.iconPath,
    required this.ef,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'subcategory': subcategory,
      'tip': tip,
      'iconPath': iconPath,
      'ef': ef,
      'unit': unit,
    };
  }

  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      category: map['category'],
      subcategory: map['subcategory'],
      tip: map['tip'],
      iconPath: map['iconPath'] ?? '',
      ef: double.tryParse(map['ef'].toString()) ?? 0.0,
      unit: double.tryParse(map['unit'].toString()) ?? 0.0,
    );
  }
}