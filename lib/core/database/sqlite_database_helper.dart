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
        await db.execute('PRAGMA foreign_keys = ON');

        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            training_id INTEGER,
            training_name_at_time TEXT,
            training_type TEXT,
            multiset_id INTEGER,
            training_exercise_id INTEGER,
            training_exercise_type TEXT,
            exercise_id INTEGER,
            exercise_name_at_time TEXT,
            set_number INTEGER,
            multiset_set_number INTEGER,
            date INTEGER,
            reps INTEGER,
            weight INTEGER,
            duration INTEGER,
            distance INTEGER,
            pace INTEGER,
            calories INTEGER,
            intensity INTEGER,
            FOREIGN KEY(training_exercise_id) REFERENCES training_exercises(id),
            FOREIGN KEY(training_id) REFERENCES trainings(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE run_locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            training_id INTEGER,
            multiset_id INTEGER,
            training_exercise_id INTEGER,
            set_number INTEGER,
            multiset_set_number INTEGER,
            latitude REAL,
            longitude REAL,
            altitude REAL,
            timestamp INTEGER,
            accuracy REAL,
            speed REAL,
            FOREIGN KEY(training_exercise_id) REFERENCES training_exercises(id),
            FOREIGN KEY(training_id) REFERENCES trainings(id)
          )
        ''');
      },
      version: 1,
    );

    return _database!;
  }
}
