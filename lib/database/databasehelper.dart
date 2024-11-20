import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'face_data.db');
    return await openDatabase(
      path,
      version: 2, // Update to version 2 for migration
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE faceContours(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empid TEXT NOT NULL,
          contourData TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE faceContours ADD COLUMN empid TEXT NOT NULL');
        }
      },
    );
  }


  Future<void> insertContourData(String empid, String contourData) async {
    final db = await database;


    await db.delete('faceContours', where: 'empid = ?', whereArgs: [empid]);

    await db.insert('faceContours', {'empid': empid, 'contourData': contourData});
  }

  Future<List<Map<String, dynamic>>> getContourData(String empid) async {
    final db = await database;
    return await db.query(
      'faceContours',
      where: 'empid = ?',
      whereArgs: [empid],
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

