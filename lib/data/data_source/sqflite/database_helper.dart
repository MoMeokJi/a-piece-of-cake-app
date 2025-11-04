import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "cake.db";
  static const _databaseVersion = 1;
  static const String diaryTableName = 'diary';

  final Future<Database> database;

  DatabaseHelper() : database = _initDatabase();

  static Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      '$path/$_databaseName',
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $diaryTableName (
        id INTEGER PRIMARY KEY,
        summary TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        firstColorHex TEXT NOT NULL,
        secondColorHex TEXT NOT NULL,
        musicTitle TEXT NOT NULL,
        musicArtist TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
