import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/waste_item.dart';
import '../models/waste_diary_entry.dart';
import '../models/travel_diary_entry.dart';
import '../models/eating_diary_entry.dart';

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
      version: _dbVersion,
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
        tip TEXT NOT NULL,
        ef DOUBLE,
        unit DOUBLE
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
        imagePath TEXT,
        carbon DOUBLE,
        unit DOUBLE
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

    await db.execute('''
      CREATE TABLE food_emission_factor (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT NOT NULL,
        variant TEXT,
        carbon REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE eating_diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        variant TEXT,
        quantity INTEGER DEFAULT 1,
        carbon REAL,
        timestamp TEXT,
        note TEXT
      )
    ''');

    // ---------- Food emission factors ----------
    await db.insert('food_emission_factor', {'food_name':'Burger','variant':'Beef','carbon':5.140434});
    await db.insert('food_emission_factor', {'food_name':'Burger','variant':'Pork','carbon':1.448394});
    await db.insert('food_emission_factor', {'food_name':'Burger','variant':'Chicken','carbon':1.106794});
    await db.insert('food_emission_factor', {'food_name':'Burger','variant':'Fish','carbon':0.693594});

    await db.insert('food_emission_factor', {'food_name':'Pad Krapow','variant':'Beef','carbon':5.19395008});
    await db.insert('food_emission_factor', {'food_name':'Pad Krapow','variant':'Pork','carbon':1.50191008});
    await db.insert('food_emission_factor', {'food_name':'Pad Krapow','variant':'Chicken','carbon':1.16031008});
    await db.insert('food_emission_factor', {'food_name':'Pad Krapow','variant':'Fish','carbon':0.74711008});

    await db.insert('food_emission_factor', {'food_name':'Salad','variant':null,'carbon':0.3040376});

    await db.insert('food_emission_factor', {'food_name':'Spaghetti','variant':'Beef','carbon':7.80368735});
    await db.insert('food_emission_factor', {'food_name':'Spaghetti','variant':'Pork','carbon':2.26562735});
    await db.insert('food_emission_factor', {'food_name':'Spaghetti','variant':'Chicken','carbon':1.75322735});
    await db.insert('food_emission_factor', {'food_name':'Spaghetti','variant':'Fish','carbon':1.13342735});

    await db.insert('food_emission_factor', {'food_name':'Steak','variant':'Beef','carbon':7.812772553});
    await db.insert('food_emission_factor', {'food_name':'Steak','variant':'Pork','carbon':2.274712553});
    await db.insert('food_emission_factor', {'food_name':'Steak','variant':'Chicken','carbon':1.762312553});
    await db.insert('food_emission_factor', {'food_name':'Steak','variant':'Fish','carbon':1.142512553});

    await db.insert('food_emission_factor', {'food_name':'Fried Rice','variant':'Beef','carbon':2.76265717});
    await db.insert('food_emission_factor', {'food_name':'Fried Rice','variant':'Pork','carbon':0.91663717});
    await db.insert('food_emission_factor', {'food_name':'Fried Rice','variant':'Chicken','carbon':0.74583717});
    await db.insert('food_emission_factor', {'food_name':'Fried Rice','variant':'Fish','carbon':0.53923717});



    // Plastic unit is weight in kilogram
    await db.insert('waste_items', {'name': 'Plastic bottle', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Remove cap and rinse before recycling.', 'ef': 4.68568, 'unit': 0.025});
    await db.insert('waste_items', {'name': 'Plastic bag', 'category': 'Plastic', 'subcategory': 'Bag', 'type': 'Trash', 'tip': 'Try to reuse before disposal.', 'ef': 8.98311, 'unit': 0.006});
    await db.insert('waste_items', {'name': 'Styrofoam box', 'category': 'Plastic', 'subcategory': 'Foam', 'type': 'Trash', 'tip': 'Styrofoam is not recyclable in most areas.', 'ef': 8.98311, 'unit': 0.020});
    await db.insert('waste_items', {'name': 'Soda bottle', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Remove cap and rinse before recycling..', 'ef': 4.68568, 'unit': 0.025});
    await db.insert('waste_items', {'name': 'Milk bottle (plastic)', 'category': 'Plastic', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Rinse well before recycling.', 'ef': 4.68568, 'unit': 0.030});
    await db.insert('waste_items', {'name': 'Snack wrapper', 'category': 'Plastic', 'subcategory': 'Bag', 'type': 'Trash', 'tip': 'Wrappers are usually multi-layered and non-recyclable.', 'ef': 8.98311, 'unit': 0.003});
    await db.insert('waste_items', {'name': 'Plastic utensils', 'category': 'Plastic', 'subcategory': 'Foam', 'type': 'Trash', 'tip': 'Consider reusable alternatives.', 'ef': 8.98311, 'unit': 0.005});

    // Glass
    await db.insert('waste_items', {'name': 'Glass bottle', 'category': 'Glass', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Rinse and remove cap before recycling.', 'ef': 4.68568, 'unit': 0.400});
    await db.insert('waste_items', {'name': 'Glass jar', 'category': 'Glass', 'subcategory': 'Jar', 'type': 'Recyclable', 'tip': 'Ensure it is clean and dry.', 'ef': 4.68568, 'unit': 0.350});
    await db.insert('waste_items', {'name': 'Broken glass', 'category': 'Glass', 'subcategory': 'Broken Glass', 'type': 'Trash', 'tip': 'Wrap in newspaper before disposal.', 'ef': 8.98311, 'unit': 0.250});
    await db.insert('waste_items', {'name': 'Perfume bottle', 'category': 'Glass', 'subcategory': 'Bottle', 'type': 'Recyclable', 'tip': 'Remove plastic cap and rinse.', 'ef': 4.68568, 'unit': 0.200});
    await db.insert('waste_items', {'name': 'Jam jar', 'category': 'Glass', 'subcategory': 'Jar', 'type': 'Recyclable', 'tip': 'Clean off food residues.', 'ef': 4.68568, 'unit': 0.300});
    await db.insert('waste_items', {'name': 'Window glass shard', 'category': 'Glass', 'subcategory': 'Broken Glass', 'type': 'Trash', 'tip': 'Wrap carefully before disposal.', 'ef': 8.98311, 'unit': 0.250});

    // Metal
    await db.insert('waste_items', {'name': 'Aluminum can', 'category': 'Metal', 'subcategory': 'Can', 'type': 'Recyclable', 'tip': 'Rinse before recycling.', 'ef': 4.68568, 'unit': 0.015});
    await db.insert('waste_items', {'name': 'Aluminum foil', 'category': 'Metal', 'subcategory': 'Foil', 'type': 'Trash', 'tip': 'Foil is not recyclable when dirty.', 'ef': 8.98311, 'unit': 0.010});
    await db.insert('waste_items', {'name': 'Tin can (food)', 'category': 'Metal', 'subcategory': 'Can', 'type': 'Recyclable', 'tip': 'Rinse and flatten if possible.', 'ef': 4.68568, 'unit': 0.050});
    await db.insert('waste_items', {'name': 'Used aluminum tray', 'category': 'Metal', 'subcategory': 'Foil', 'type': 'Trash', 'tip': 'Too contaminated for recycling.', 'ef': 8.98311, 'unit': 0.030});

    // Paper
    await db.insert('waste_items', {'name': 'Newspaper', 'category': 'Paper', 'subcategory': 'Newspaper', 'type': 'Recyclable', 'tip': 'Keep dry and unsoiled.', 'ef': 4.68568, 'unit': 0.200});
    await db.insert('waste_items', {'name': 'Cardboard box', 'category': 'Paper', 'subcategory': 'Cardboard', 'type': 'Recyclable', 'tip': 'Flatten before placing in bin.', 'ef': 4.68568, 'unit': 0.500});
    await db.insert('waste_items', {'name': 'Used tissue', 'category': 'Paper', 'subcategory': 'Tissue', 'type': 'Trash', 'tip': 'Used tissue is not recyclable.', 'ef': 1164.48940, 'unit': 0.002});
    await db.insert('waste_items', {'name': 'Flyer', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Recyclable', 'tip': 'Only recycle if clean and dry.', 'ef': 4.68568, 'unit': 0.010});
    await db.insert('waste_items', {'name': 'Magazine', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Recyclable', 'tip': 'Avoid wet or glossy paper with plastic coating.', 'ef': 4.68568, 'unit': 0.250});
    await db.insert('waste_items', {'name': 'Paper cup', 'category': 'Paper', 'subcategory': 'Mixed Paper', 'type': 'Trash', 'tip': 'Often lined with plastic, not recyclable.', 'ef': 1164.48940, 'unit': 0.015});
    await db.insert('waste_items', {'name': 'Used napkin', 'category': 'Paper', 'subcategory': 'Tissue', 'type': 'Trash', 'tip': 'Contaminated tissue should go to general waste.', 'ef': 1164.48940, 'unit': 0.003});
    // Food
    await db.insert('waste_items', {'name': 'Cooked rice', 'category': 'Food', 'subcategory': 'Leftovers', 'type': 'Compost', 'tip': 'Avoid oily or spicy food in compost.', 'ef': 8.98311, 'unit': 0.200});
    await db.insert('waste_items', {'name': 'Chicken bones', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Industrial compost only; not for home compost.', 'ef': 8.98311, 'unit': 0.150});
    await db.insert('waste_items', {'name': 'Banana peel', 'category': 'Food', 'subcategory': 'Fruit/Vegetable', 'type': 'Compost', 'tip': 'Great for compost bins.', 'ef': 8.98311, 'unit': 0.040});
    await db.insert('waste_items', {'name': 'Apple core', 'category': 'Food', 'subcategory': 'Fruit', 'type': 'Compost', 'tip': 'Safe for home compost.', 'ef': 8.98311, 'unit': 0.050});
    await db.insert('waste_items', {'name': 'Eggshells', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Crush before composting.', 'ef': 8.98311, 'unit': 0.010});
    await db.insert('waste_items', {'name': 'Fish bones', 'category': 'Food', 'subcategory': 'Shells & Bones', 'type': 'Compost', 'tip': 'Better for industrial composting.', 'ef': 8.98311, 'unit': 0.120});

    // Textile
    await db.insert('waste_items', {'name': 'Old T-shirt', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Donate if in good condition, otherwise discard.', 'ef': 496.78228, 'unit': 0.180});
    await db.insert('waste_items', {'name': 'Old jeans', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Donate if wearable. Recycle if textile bins available.', 'ef': 496.78228, 'unit': 0.600});
    await db.insert('waste_items', {'name': 'Socks (pair)', 'category': 'Textile', 'subcategory': 'Clothing', 'type': 'Trash', 'tip': 'Can be used as cleaning rags if not too worn.', 'ef': 496.78228, 'unit': 0.060});
    await db.insert('waste_items', {'name': 'Old blanket', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Donate to animal shelters or recycle if possible.', 'ef': 496.78228, 'unit': 1.200});
    await db.insert('waste_items', {'name': 'Worn-out towel', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Cut into cleaning cloths before discarding.', 'ef': 496.78228, 'unit': 0.500});
    await db.insert('waste_items', {'name': 'Used curtains', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Donate or recycle if textile recycling is available.', 'ef': 496.78228, 'unit': 1.500});
    await db.insert('waste_items', {'name': 'Fabric scraps', 'category': 'Textile', 'subcategory': 'Fabric Waste', 'type': 'Trash', 'tip': 'Can be reused for crafts or recycled in textile bins.', 'ef': 496.78228, 'unit': 0.200});
    await db.insert('waste_items', {'name': 'Shoes (pair)', 'category': 'Textile', 'subcategory': 'Footwear', 'type': 'Trash', 'tip': 'Donate if wearable, otherwise dispose properly.', 'ef': 496.78228, 'unit': 0.800});
    await db.insert('waste_items', {'name': 'Old pillow', 'category': 'Textile', 'subcategory': 'Household Fabric', 'type': 'Trash', 'tip': 'Not usually recyclable; reuse or discard.', 'ef': 496.78228, 'unit': 0.700});

    // Other
    await db.insert('waste_items', {'name': 'Battery', 'category': 'Other', 'subcategory': 'Battery', 'type': 'Hazardous', 'tip': 'Dispose at battery collection point.', 'ef': 8.98311, 'unit': 0.023});
    await db.insert('waste_items', {'name': 'Broken phone charger', 'category': 'Other', 'subcategory': 'E-Waste', 'type': 'E-Waste', 'tip': 'Recycle at e-waste drop-off center.', 'ef': 8.98311, 'unit': 0.120});
    await db.insert('waste_items', {'name': 'Broken thermometer', 'category': 'Other', 'subcategory': 'Hazardous', 'type': 'Hazardous', 'tip': 'Do not throw in bin; hazardous mercury inside.', 'ef': 8.98311, 'unit': 0.050});
    await db.insert('waste_items', {'name': 'Button cell battery', 'category': 'Other', 'subcategory': 'Battery', 'type': 'Hazardous', 'tip': 'Dispose at electronics/battery collection point.', 'ef': 8.98311, 'unit': 0.003});
    await db.insert('waste_items', {'name': 'Old laptop', 'category': 'Other', 'subcategory': 'E-Waste', 'type': 'E-Waste', 'tip': 'Drop off at an e-waste center or store with take-back program.', 'ef': 8.98311, 'unit': 2.000});
    await db.insert('waste_items', {'name': 'Paint can (used)', 'category': 'Other', 'subcategory': 'Hazardous', 'type': 'Hazardous', 'tip': 'Take to hazardous waste collection.', 'ef': 8.98311, 'unit': 0.500});

    // Symbol
    await db.insert('waste_items', {'name': '♳ PET (1)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'plastic_code_1.png', 'tip': 'Used in water or beverage bottles. Recyclable.'});
    await db.insert('waste_items', {'name': '♴ HDPE (2)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'plastic_code_2.png', 'tip': 'Used in shampoo bottles or cleaning product containers. Recyclable.'});
    await db.insert('waste_items', {'name': '♵ PVC (3)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'plastic_code_3.png', 'tip': 'Used in pipes or plastic films. Difficult to recycle.'});
    await db.insert('waste_items', {'name': '♶ LDPE (4)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'plastic_code_4.png', 'tip': 'Used in plastic bags or food wrap. Recyclable in some areas.'});
    await db.insert('waste_items', {'name': '♷ PP (5)', 'category': 'Symbol Guide', 'subcategory': 'Recyclable Plastic', 'type': 'plastic_code_5.png', 'tip': 'Used in food containers and plastic utensils. Recyclable.'});
    await db.insert('waste_items', {'name': '♸ PS (6)', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'plastic_code_6.png', 'tip': 'Used in foam or food packaging. -> Hard to recycle.'});
    await db.insert('waste_items', {'name': '♹ Other (7)', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'plastic_code_7.png', 'tip': 'Other plastics such as PC, ABS. -> Mostly non-recyclable.'});
    await db.insert('waste_items', {'name': 'Radioactive', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'radioactive.png', 'tip': 'Handle with extreme caution. Contact specialized hazardous waste facilities or government agency for disposal.'});
    await db.insert('waste_items', {'name': 'Biohazard', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'biohazard.png', 'tip': 'Dispose through medical waste services. Do not throw in general waste bins.'});
    await db.insert('waste_items', {'name': 'Flammable', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'flammable.png', 'tip': 'Keep away from heat or flame. Bring to a hazardous waste collection center.'});
    await db.insert('waste_items', {'name': 'Toxic/Poisonous', 'category': 'Symbol Guide', 'subcategory': 'Non-Recyclable', 'type': 'toxic.png', 'tip': 'Do not dispose in drains or bins. Take to a toxic waste facility or special collection point.'});
  }

static const int _dbVersion = 7;

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2: add carbon column
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE waste_diary_log ADD COLUMN carbon REAL DEFAULT 0.0',
      );
    }

    // v3: add category to waste_items
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE waste_items ADD COLUMN category TEXT');
      await db.rawUpdate(
        'UPDATE waste_items SET category = "Other" WHERE category IS NULL',
      );
    }

    // v4: add missing diary fields (only if they did not exist before)
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE waste_diary_log ADD COLUMN quantity INTEGER DEFAULT 1',
      );
      await db.execute('ALTER TABLE waste_diary_log ADD COLUMN note TEXT');
      await db.execute('ALTER TABLE waste_diary_log ADD COLUMN imagePath TEXT');
    }

    // v5: travel diary table
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

    if (oldVersion < 6) {
  await db.execute('''
    UPDATE waste_items
    SET ef = CAST(ef AS REAL),
        unit = CAST(unit AS REAL)
    WHERE ef IS NULL OR unit IS NULL
  ''');
}
    if (oldVersion < 7) {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS food_emission_factor (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      food_name TEXT NOT NULL,
      variant TEXT,
      carbon REAL NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS eating_diary (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      variant TEXT,
      quantity INTEGER DEFAULT 1,
      carbon REAL,
      timestamp TEXT,
      note TEXT
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

  // --------------------------- Travel Diary ---------------------------
  
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

  // --------------------------- Eating Diary ---------------------------

  Future<List<EatingDiaryEntry>> getAllEatingDiaryEntries() async {
    final db = await database;
    final maps = await db.query('eating_diary',
    orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => EatingDiaryEntry.fromMap(maps[i]));
  }

Future<int> insertEatingDiaryEntry(EatingDiaryEntry entry) async {
  final db = await database;
  print(
    "Saving eating diary: ${entry.name} (${entry.variant}) - ${entry.carbon}",
  );

  return await db.insert(
    'eating_diary',
    entry.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<double> getFoodCarbon(String food, String? variant) async {
  final db = await database;

  // Normalize input
  final foodKey = food.trim();
  final variantKey = variant?.trim();

  List<Map<String, dynamic>> result;

  if (variantKey == null || variantKey.isEmpty) {
    // For foods like Salad
    result = await db.query(
      'food_emission_factor',
      where: 'food_name = ? AND variant IS NULL',
      whereArgs: [foodKey],
    );
  } else {
    result = await db.query(
      'food_emission_factor',
      where: 'food_name = ? AND variant = ?',
      whereArgs: [foodKey, variantKey],
    );
  }

  if (result.isEmpty) {
    debugPrint('[DB] ❌ No match for food=$foodKey variant=$variantKey');
    return 0.0;
  }

  final carbon = (result.first['carbon'] as num).toDouble();

  debugPrint(
    '[DB] ✅ Match food=$foodKey variant=$variantKey carbon=$carbon',
  );

  return carbon;
}

}