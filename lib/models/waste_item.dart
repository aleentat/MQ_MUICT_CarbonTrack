class WasteItem {
  final int id;
  final String name;
  final String type;
  final String category;
  final String subcategory;
  final String tip;
  final String iconPath;

  WasteItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.subcategory,
    required this.tip,
    required this.iconPath,
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
    );
  }
}