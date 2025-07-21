import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';
import '../models/travel_diary_entry.dart';

class DBHelper {
  DBHelper._privateConstructor();  
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<void> exportDatabase() async {
  try {
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'waste_items.db')); 

    if (!await dbFile.exists()) {
      print('❌ Database file not found.');
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final copiedFile = await dbFile.copy('${tempDir.path}/waste_exported.db');
    print('✅ Exported DB Path: ${copiedFile.path}');

    await Share.shareXFiles(
      [XFile(copiedFile.path)],
      text: '🗂️ Exported Waste Diary DB',
    );
  } catch (e) {
    print('❌ Error exporting DB: $e');
    }
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'waste_items.db');
    print('SQLite Path: $dbPath');

    return await openDatabase(
      path,
      version: 5,
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
        timestamp TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        note TEXT,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE travel_diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startLocation TEXT,
        endLocation TEXT,
        mode TEXT,
        distance REAL,
        carbon REAL,
        timestamp TEXT
      )
    ''');
    // Plastic
    await db.insert('waste_items', {'name': 'Plastic bottle', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Remove cap and rinse before recycling.'});
    await db.insert('waste_items', {'name': 'Plastic bag', 'category': 'Plastic', 'subcategory': 'Bag', 'type': 'Trash', 'tip': 'Try to reuse before disposal.'});
    await db.insert('waste_items', {'name': 'Styrofoam box', 'category': 'Plastic', 'subcategory': 'Foam', 'type': 'Trash', 'tip': 'Styrofoam is not recyclable in most areas.'});
    await db.insert('waste_items', {'name': 'Soda bottle', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Rinse before recycling. Remove cap and label.'});
    await db.insert('waste_items', {'name': 'Milk bottle (plastic)', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Rinse well before recycling.'});
    await db.insert('waste_items', {'name': 'Snack wrapper', 'category': 'Plastic', 'subcategory': 'Bag', 'type': 'Trash', 'tip': 'Wrappers are usually multi-layered and non-recyclable.'});
    await db.insert('waste_items', {'name': 'Plastic utensils', 'category': 'Plastic', 'subcategory': 'Foam', 'type': 'Trash', 'tip': 'Consider reusable alternatives.'});

    // Glass
    await db.insert('waste_items', {'name': 'Glass bottle', 'category': 'Glass', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Rinse and remove cap before recycling.'});
    await db.insert('waste_items', {'name': 'Glass jar', 'category': 'Glass', 'subcategory': 'Jar', 'type': 'Recyclable', 'tip': 'Ensure it is clean and dry.'});
    await db.insert('waste_items', {'name': 'Broken glass', 'category': 'Glass', 'subcategory': 'Broken Glass', 'type': 'Trash', 'tip': 'Wrap in newspaper before disposal.'});
    await db.insert('waste_items', {'name': 'Perfume bottle', 'category': 'Glass', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Remove plastic cap and rinse.'});
    await db.insert('waste_items', {'name': 'Jam jar', 'category': 'Glass', 'subcategory': 'Jar', 'type': 'Recyclable', 'tip': 'Clean off food residues.'});
    await db.insert('waste_items', {'name': 'Window glass shard', 'category': 'Glass', 'subcategory': 'Broken Glass', 'type': 'Trash', 'tip': 'Wrap carefully before disposal.'});

    // Metal
    await db.insert('waste_items', {'name': 'Aluminum can', 'category': 'Metal', 'subcategory': 'Can', 'type': 'Recyclable', 'tip': 'Rinse before recycling.'});
    await db.insert('waste_items', {'name': 'Aluminum foil', 'category': 'Metal', 'subcategory': 'Foil', 'type': 'Trash', 'tip': 'Foil is not recyclable when dirty.'});
    await db.insert('waste_items', {'name': 'Tin can (food)', 'category': 'Metal', 'subcategory': 'Can', 'type': 'Recyclable', 'tip': 'Rinse and flatten if possible.'});
    await db.insert('waste_items', {'name': 'Used aluminum tray', 'category': 'Metal', 'subcategory': 'Foil', 'type': 'Trash', 'tip': 'Too contaminated for recycling.'});

    // Paper
    await db.insert('waste_items', {'name': 'Newspaper', 'category': 'Paper', 'subcategory': 'Newspaper', 'type': 'Recyclable', 'tip': 'Keep dry and unsoiled.'});
    await db.insert('waste_items', {'name': 'Cardboard box', 'category': 'Paper', 'subcategory': 'Cardboard', 'type': 'Recyclable', 'tip': 'Flatten before placing in bin.'});
    await db.insert('waste_items', {'name': 'Used tissue', 'category': 'Paper', 'subcategory': 'Tissue', 'type': 'Trash', 'tip': 'Used tissue is not recyclable.'});
    await db.insert('waste_items', {'name': 'Flyer', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Recyclable', 'tip': 'Only recycle if clean and dry.'});
    await db.insert('waste_items', {'name': 'Magazine', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Recyclable', 'tip': 'Avoid wet or glossy paper with plastic coating.'});
    await db.insert('waste_items', {'name': 'Paper cup', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Trash', 'tip': 'Often lined with plastic, not recyclable.'});
    await db.insert('waste_items', {'name': 'Used napkin', 'category': 'Paper', 'subcategory': 'Tissue', 'type': 'Trash', 'tip': 'Contaminated tissue should go to general waste.'});

    // Food
    await db.insert('waste_items', {'name': 'Cooked rice', 'category': 'Food', 'subcategory': 'Leftovers', 'type': 'Compost', 'tip': 'Avoid oily or spicy food in compost.'});
    await db.insert('waste_items', {'name': 'Chicken bones', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Industrial compost only; not for home compost.'});
    await db.insert('waste_items', {'name': 'Banana peel', 'category': 'Food', 'subcategory': 'Fruit/Vegetable', 'type': 'Compost', 'tip': 'Great for compost bins.'});
    await db.insert('waste_items', {'name': 'Cooked rice', 'category': 'Food', 'subcategory': 'Leftovers', 'type': 'Compost', 'tip': 'Avoid oily foods in home compost.'});
    await db.insert('waste_items', {'name': 'Apple core', 'category': 'Food', 'subcategory': 'Fruit', 'type': 'Compost', 'tip': 'Safe for home compost.'});
    await db.insert('waste_items', {'name': 'Eggshells', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Crush before composting.'});
    await db.insert('waste_items', {'name': 'Fish bones', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Better for industrial composting.'});

    // Textile
    await db.insert('waste_items', {'name': 'Old T-shirt', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Donate if in good condition, otherwise discard.'});
    await db.insert('waste_items', {'name': 'Old jeans', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Donate if wearable. Recycle if textile bins available.'});
    await db.insert('waste_items', {'name': 'Socks with holes', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Can be used as cleaning rags if not too worn.'});
    await db.insert('waste_items', {'name': 'Old blanket', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Donate to animal shelters or recycle if possible.'});
    await db.insert('waste_items', {'name': 'Worn-out towel', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Cut into cleaning cloths before discarding.'});
    await db.insert('waste_items', {'name': 'Used curtains', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Donate or recycle if textile recycling is available.'});
    await db.insert('waste_items', {'name': 'Fabric scraps', 'category': 'Textile', 'subcategory': 'Fabric Waste', 'type': 'Trash', 'tip': 'Can be reused for crafts or recycled in textile bins.'});
    await db.insert('waste_items', {'name': 'Shoes (worn out)', 'category': 'Textile', 'subcategory': 'Footwear', 'type': 'Trash', 'tip': 'Donate if wearable, otherwise dispose properly.'});
    await db.insert('waste_items', {'name': 'Old pillow', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Not usually recyclable; reuse or discard.'});

    // Other
    await db.insert('waste_items', {'name': 'Battery', 'category': 'Other', 'subcategory': 'Battery', 'type': 'Hazardous', 'tip': 'Dispose at battery collection point.'});
    await db.insert('waste_items', {'name': 'Broken phone charger', 'category': 'Other', 'subcategory': 'E-Waste', 'type': 'E-Waste', 'tip': 'Recycle at e-waste drop-off center.'});
    await db.insert('waste_items', {'name': 'Broken thermometer', 'category': 'Other', 'subcategory': 'Hazardous', 'type': 'Hazardous', 'tip': 'Do not throw in bin; hazardous mercury inside.'});
    await db.insert('waste_items', {'name': 'Button cell battery', 'category': 'Other', 'subcategory': 'Battery', 'type': 'Hazardous', 'tip': 'Dispose at electronics/battery collection point.'});
    await db.insert('waste_items', {'name': 'Old laptop', 'category': 'Other', 'subcategory': 'E-Waste', 'type': 'E-Waste', 'tip': 'Drop off at an e-waste center or store with take-back program.'});
    await db.insert('waste_items', {'name': 'Paint can (used)', 'category': 'Other', 'subcategory': 'Hazardous', 'type': 'Hazardous', 'tip': 'Take to hazardous waste collection.'});
  
    // Symbol
    await db.insert('waste_items', {'name': '♳ PET (1)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_1.png', 'tip': 'Used in water or beverage bottles. Recyclable.'});
    await db.insert('waste_items', {'name': '♴ HDPE (2)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_2.png', 'tip': 'Used in shampoo bottles or cleaning product containers. Recyclable.'});
    await db.insert('waste_items', {'name': '♵ PVC (3)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_3.png', 'tip': 'Used in pipes or plastic films. Difficult to recycle.'});
    await db.insert('waste_items', {'name': '♶ LDPE (4)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_4.png', 'tip': 'Used in plastic bags or food wrap. Recyclable in some areas.'});
    await db.insert('waste_items', {'name': '♷ PP (5)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_5.png', 'tip': 'Used in food containers and plastic utensils. Recyclable.'});
    await db.insert('waste_items', {'name': '♸ PS (6)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_6.png', 'tip': 'Used in foam or food packaging. Hard to recycle.'});
    await db.insert('waste_items', {'name': '♹ Other (7)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'assets/images/symbols/plastic_code_7.png', 'tip': 'Other plastics such as PC, ABS. Mostly non-recyclable.'});
    await db.insert('waste_items', {'name': 'Radioactive', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'assets/images/symbols/radioactive.png', 'tip': 'Handle with extreme caution. Contact specialized hazardous waste facilities or government agency for disposal.'});
    await db.insert('waste_items', {'name': 'Biohazard', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'assets/images/symbols/biohazard.png', 'tip': 'Dispose through medical waste services. Do not throw in general waste bins.'});
    await db.insert('waste_items', {'name': 'Flammable', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'assets/images/symbols/flammable.png', 'tip': 'Keep away from heat or flame. Bring to a hazardous waste collection center.'});
    await db.insert('waste_items', {'name': 'Toxic/Poisonous', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'assets/images/symbols/toxic.png', 'tip': 'Do not dispose in drains or bins. Take to a toxic waste facility or special collection point.'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE waste_diary_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp TEXT NOT NULL
          quantity INTEGER NOT NULL,
          note TEXT,
          imagePath TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE waste_items ADD COLUMN category TEXT');
      await db.rawUpdate('UPDATE waste_items SET category = "Other" WHERE category IS NULL');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE waste_diary_log ADD COLUMN quantity INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE waste_diary_log ADD COLUMN note TEXT');
      await db.execute('ALTER TABLE waste_diary_log ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS travel_diary (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          startLocation TEXT,
          endLocation TEXT,
          mode TEXT,
          distance REAL,
          carbon REAL,
          timestamp TEXT
        )
      ''');
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
    final maps = await db.query('waste_diary_log',
    orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => WasteDiaryEntry.fromMap(maps[i]));
  }

  // --------------------------- Waste Diary ---------------------------
  
  Future<int> insertTravelDiaryEntry(TravelDiaryEntry entry) async {
    final db = await instance.database;
    print("Saving to diary: ${entry.startLocation} -> ${entry.endLocation}, ${entry.carbon}, ${entry.timestamp}");
    return await db.insert('travel_diary', entry.toMap());
  }

  Future<List<TravelDiaryEntry>> getAllTravelDiaryEntries() async {
    final db = await database;
    final result = await db.query('travel_diary');
    return result.map((e) => TravelDiaryEntry.fromMap(e)).toList();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}