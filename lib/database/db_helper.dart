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
      version: 2, // Increased version for new table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE waste_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
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
    // sample
    await db.insert('waste_items', {'name': 'Banana Peel', 'type': 'Compost'});
    await db.insert('waste_items', {'name': 'Plastic Bottle', 'type': 'Recyclable'});
    await db.insert('waste_items', {'name': 'Styrofoam Box', 'type': 'Trash'});
    await db.insert('waste_items', {'name': 'Newspaper', 'type': 'Recyclable'});
    await db.insert('waste_items', {'name': 'Leftover Food', 'type': 'Compost'});
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
  }

  // Waste Items
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
    final List<Map<String, dynamic>> maps = await db.query('waste_items');
    return List.generate(maps.length, (i) => WasteItem.fromMap(maps[i]));
  }

  Future<int> deleteWasteItem(int id) async {
    final db = await database;
    return await db.delete(
      'waste_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Waste Diary Log
  Future<int> insertWasteDiaryEntry(WasteDiaryEntry entry) async {
    final db = await database;
    return await db.insert(
      'waste_diary_log',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WasteDiaryEntry>> getAllWasteDiaryEntries() async {
    final db = await database;
    final maps = await db.query('waste_diary_log');

    return List.generate(maps.length, (i) => WasteDiaryEntry.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}