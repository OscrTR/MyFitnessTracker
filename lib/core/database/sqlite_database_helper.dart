import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDatabaseHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'my_fitness_tracker.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            description TEXT, 
            image_path TEXT
          )
        ''');
      },
      version: 1,
    );

    return _database!;
  }
}
