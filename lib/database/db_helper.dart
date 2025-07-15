import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';

class DBHelper {
  DBHelper._privateConstructor();  
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'waste_items.db');

    print("DB Path: $path");

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE waste_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT NOT NULL,
        tip TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE waste_diary_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.insert('waste_items', {'name': 'Banana peel', 'type': 'Compost', 'category': 'Food', 'subcategory': 'Fruit/Vegetable', 'tip': 'Great for compost bins.'});
    await db.insert('waste_items', {'name': 'Soda bottle', 'type': 'Recyclable', 'category': 'Plastic', 'subcategory': 'Bottle', 'tip': 'Rinse before recycling. Remove cap and label.'});
    await db.insert('waste_items', {'name': 'Styrofoam food box', 'type': 'Trash', 'category': 'Plastic', 'subcategory': 'Foam', 'tip': 'Styrofoam is not recyclable in most areas.'});
    await db.insert('waste_items', {'name': 'Flyers', 'type': 'Recyclable', 'category': 'Paper', 'subcategory': 'Newspaper', 'tip': 'Dry and clean only.'});
    await db.insert('waste_items', {'name': 'Cooked rice', 'type': 'Compost', 'category': 'Food', 'subcategory': 'Leftovers', 'tip': 'Avoid oily foods in home compost.'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE waste_diary_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE waste_items ADD COLUMN category TEXT');
      await db.rawUpdate('UPDATE waste_items SET category = "Other" WHERE category IS NULL');
    }
  }

  // --------------------------- Waste Items ---------------------------

  Future<int> insertWasteItem(WasteItem item) async {
    final db = await database;
    return await db.insert(
      'waste_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WasteItem>> getWasteItems() async {
    final db = await database;
    final maps = await db.query('waste_items');
    return List.generate(maps.length, (i) => WasteItem.fromMap(maps[i]));
  }

  Future<List<WasteItem>> getWasteItemsFiltered({String? category, String? subcategory}) async {
    final db = await database;

    String whereClause = '';
    List<String> whereArgs = [];

    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (subcategory != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'subcategory = ?';
      whereArgs.add(subcategory);
    }

    final maps = await db.query(
      'waste_items',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) => WasteItem.fromMap(maps[i]));
  }

  Future<List<String>> getDistinctCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM waste_items ORDER BY category ASC');
    return result.map((row) => row['category'] as String).toList();
  }

  Future<List<String>> getDistinctSubcategoriesByCategory(String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT subcategory FROM waste_items WHERE category = ? ORDER BY subcategory ASC',
      [category],
    );
    return result.map((row) => row['subcategory'] as String).toList();
  }

  Future<int> deleteWasteItem(int id) async {
    final db = await database;
    return await db.delete(
      'waste_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------------- Waste Diary ---------------------------

  Future<int> insertWasteDiaryEntry(WasteDiaryEntry entry) async {
    final db = await database;
    print("Saving to diary: ${entry.name}, ${entry.type}, ${entry.timestamp}");
    return await db.insert(
      'waste_diary_log',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WasteDiaryEntry>> getAllWasteDiaryEntries() async {
    final db = await database;
    final maps = await db.query('waste_diary_log');
    print("Fetched ${maps.length} diary entries");
    return List.generate(maps.length, (i) => WasteDiaryEntry.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}