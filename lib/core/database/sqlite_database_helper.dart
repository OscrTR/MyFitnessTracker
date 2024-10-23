import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDatabaseHelper {
  static Database? _database;

  // Singleton pattern to ensure only one database instance
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'my_fitness_tracker.db'),
      onCreate: (db, version) async {
        // Create all necessary tables
        await db.execute('''
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            description TEXT, 
            image_name TEXT
          )
        ''');
      },
      version: 1,
    );

    return _database!;
  }
}
