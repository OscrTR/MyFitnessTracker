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
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT,
            exercise_type INTEGER,
            description TEXT, 
            image_path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE trainings(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            type INTEGER, 
            is_selected INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE multisets(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            training_id INTEGER,
            sets INTEGER,
            set_rest INTEGER,
            multiset_rest INTEGER,
            special_instructions TEXT,
            objectives TEXT,
            position INTEGER,
            key TEXT,
            FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE training_exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            training_id INTEGER,
            multiset_id INTEGER,
            exercise_id INTEGER,
            training_exercise_type INTEGER,
            sets INTEGER,
            is_sets_in_reps INTEGER,
            min_reps INTEGER,
            max_reps INTEGER,
            duration INTEGER,
            set_rest INTEGER,
            exercise_rest INTEGER,
            auto_start INTEGER,
            run_exercise_target INTEGER,
            target_distance INTEGER,
            target_duration INTEGER,
            is_target_pace_selected INTEGER,
            target_pace INTEGER,
            intervals INTEGER,
            is_interval_in_distance INTEGER,
            interval_distance INTEGER,
            interval_duration INTEGER,
            interval_rest INTEGER,
            special_instructions TEXT,
            objectives TEXT,
            position INTEGER,
            key TEXT,
            FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE,
            FOREIGN KEY(multiset_id) REFERENCES multisets(id) ON DELETE CASCADE,
            FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            training_id INTEGER,
            training_exercise_id INTEGER,
            set_number INTEGER,
            multiset_set_number INTEGER,
            date INTEGER,
            reps INTEGER,
            duration INTEGER,
            distance INTEGER,
            pace INTEGER,
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
