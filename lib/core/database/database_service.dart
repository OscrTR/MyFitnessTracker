import '../../features/training_history/models/history_training.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';
import '../messages/toast.dart';
import '../enums/enums.dart';
import '../../features/training_management/models/reminder.dart';
import '../../features/base_exercise_management/models/base_exercise.dart';
import '../../features/training_history/models/history_entry.dart';
import '../../features/training_history/models/history_run_location.dart';
import '../../features/training_management/models/multiset.dart';
import '../../features/training_history/models/training_version.dart';
import '../../features/training_management/models/exercise.dart';
import '../../features/training_management/models/training.dart';

import '../messages/models/log.dart';

class DatabaseService {
  late final SqliteDatabase _db;

  final migrations = SqliteMigrations()
    ..add(SqliteMigration(2, (tx) async {
      await tx.execute('DROP TABLE exercises');
      await tx.execute('DROP TABLE trainings');
      await tx.execute('DROP TABLE reminders');
      await tx.execute('DROP TABLE multisets');
      await tx.execute('DROP TABLE training_versions');
      await tx.execute('DROP TABLE history_entries');
      await tx.execute('DROP TABLE run_locations');
      await tx.execute('DROP TABLE logs');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    notificationId INTEGER NOT NULL,
    day TEXT NOT NULL
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    isReminderActive INTEGER NOT NULL
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS base_exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    imagePath TEXT,
    description TEXT NOT NULL,
    muscleGroups TEXT NOT NULL
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS trainings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    trainingType TEXT NOT NULL,
    objectives TEXT NOT NULL,
    trainingDays TEXT NOT NULL
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS multisets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trainingId INTEGER,
    sets INTEGER NOT NULL,
    setRest INTEGER NOT NULL,
    multisetRest INTEGER NOT NULL,
    specialInstructions TEXT NOT NULL,
    objectives TEXT NOT NULL,
    position INTEGER,
    widgetKey TEXT,
    FOREIGN KEY (trainingId) REFERENCES trainings (id)
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trainingId INTEGER,
    multisetId INTEGER,
    baseExerciseId INTEGER,
    exerciseType TEXT NOT NULL,
    runType TEXT NOT NULL,
    specialInstructions TEXT NOT NULL,
    objectives TEXT NOT NULL,
    targetDistance INTEGER NOT NULL,
    targetDuration INTEGER NOT NULL,
    isTargetPaceSelected INTEGER NOT NULL,
    targetPace REAL NOT NULL,
    sets INTEGER NOT NULL,
    isSetsInReps INTEGER NOT NULL,
    minReps INTEGER NOT NULL,
    maxReps INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    setRest INTEGER NOT NULL,
    exerciseRest INTEGER NOT NULL,
    isAutoStart INTEGER NOT NULL,
    position INTEGER,
    intensity INTEGER NOT NULL,
    widgetKey TEXT,
    multisetKey TEXT,
    FOREIGN KEY (trainingId) REFERENCES trainings (id),
    FOREIGN KEY (multisetId) REFERENCES multisets (id),
    FOREIGN KEY (baseExerciseId) REFERENCES base_exercises (id)
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS training_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trainingId INTEGER,
    jsonRepresentation TEXT NOT NULL,
    FOREIGN KEY (trainingId) REFERENCES trainings (id)
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS history_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trainingId INTEGER NOT NULL,
    exerciseId INTEGER NOT NULL,
    trainingVersionId INTEGER NOT NULL,
    setNumber INTEGER NOT NULL,
    intervalNumber INTEGER,
    date INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    distance INTEGER NOT NULL,
    pace REAL NOT NULL,
    calories INTEGER NOT NULL,
    FOREIGN KEY (trainingId) REFERENCES trainings (id),
    FOREIGN KEY (exerciseId) REFERENCES exercises (id),
    FOREIGN KEY (trainingVersionId) REFERENCES training_versions (id)
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS run_locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trainingId INTEGER NOT NULL,
    exerciseId INTEGER NOT NULL,
    trainingVersionId INTEGER NOT NULL,
    setNumber INTEGER NOT NULL,
    intervalNumber INTEGER,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    altitude REAL NOT NULL,
    date INTEGER NOT NULL,
    accuracy REAL NOT NULL,
    pace REAL NOT NULL,
    FOREIGN KEY (trainingId) REFERENCES trainings (id),
    FOREIGN KEY (exerciseId) REFERENCES exercises (id),
    FOREIGN KEY (trainingVersionId) REFERENCES training_versions (id)
  )
  ''');

      await tx.execute('''
  CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    level TEXT NOT NULL,
    function TEXT,
    message TEXT,
    date INTEGER NOT NULL
  )
  ''');

      await tx.execute('''
  CREATE INDEX idx_history_entries_trainingId ON history_entries(trainingId)
  ''');

      await tx.execute('''
  CREATE INDEX idx_training_versions_trainingId ON training_versions(trainingId)
  ''');

      await tx.execute('''
  CREATE INDEX idx_exercises_multisetId ON exercises(multisetId)
  ''');

      await tx.execute('''
  CREATE INDEX idx_exercises_trainingId ON exercises(trainingId)
  ''');

      await tx.execute('''
  CREATE INDEX idx_multisets_trainingId ON multisets(trainingId)
  ''');

      await tx.execute('''
  CREATE INDEX idx_history_entries_date ON history_entries(date)
  ''');

      await tx.execute('''
  CREATE INDEX idx_run_locations_date ON run_locations(date)
  ''');

      await tx.execute('''
  CREATE INDEX idx_history_entries_trainingId_date ON history_entries(trainingId, date)
  ''');

      await tx.execute(
        'INSERT INTO logs (level, function, message, date) VALUES (?, ?, ?, ?)',
        [
          "INFO", // Niveau de log
          "init", // Fonction
          "Migration succeeded.", // Message
          DateTime.now().millisecondsSinceEpoch // Date en millisecondes
        ],
      );
    }));

  Future<void> performMaintenance() async {
    try {
      await _db.execute('VACUUM;');
      await _db.execute('ANALYZE;');
      await deleteOldLogs();
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'performMaintenance',
      );
    }
  }

  // Initialisation de la base de données
  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = join(directory.path, 'mft.db');

      _db = SqliteDatabase(path: dbPath);

      await migrations.migrate(_db);
    } catch (e) {
      await createLog(Log(
        date: DateTime.now(),
        message: e.toString(),
        level: LogLevel.error,
        function: 'init',
      ));
    }
  }

  String generateInsertSQL(String tableName, Map<String, dynamic> map) {
    final columns = map.keys.join(', ');
    final placeholders = map.keys.map((_) => '?').join(', ');
    return 'INSERT INTO $tableName ($columns) VALUES ($placeholders)';
  }

  Future<int> insert(String tableName, Map<String, dynamic> fields) async {
    try {
      // Exclut 'id' car auto incrémenté
      final cleanFields = Map.of(fields)..remove('id');

      final sql = generateInsertSQL(tableName, cleanFields);
      await _db.execute(sql, cleanFields.values.toList());
      final result = await _db.execute('SELECT last_insert_rowid()');
      return result.first.values.first as int;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'insert',
      );

      return -1;
    }
  }

  String generateUpdateSQL(
      String tableName, Map<String, dynamic> fields, String whereClause) {
    final updates = fields.keys.map((key) => '$key = ?').join(', ');
    return 'UPDATE $tableName SET $updates WHERE $whereClause';
  }

  Future<void> update(String tableName, Map<String, dynamic> fields,
      String whereClause, List<Object?> whereArgs) async {
    try {
      // Exclut 'id' car auto incrémenté
      final cleanFields = Map.of(fields)..remove('id');

      final sql = generateUpdateSQL(tableName, cleanFields, whereClause);
      final allArgs = [...cleanFields.values, ...whereArgs];
      await _db.execute(sql, allArgs);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'update',
      );
    }
  }

  //! Create operations

  Future<void> createLog(Log log) async {
    try {
      await insert('logs', log.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: false,
        logLevel: LogLevel.error,
        logFunction: 'createLog',
      );
    }
  }

  Future<int> createBaseExercise(BaseExercise baseExercise) async {
    try {
      return await insert('base_exercises', baseExercise.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createBaseExercise',
      );

      return -1;
    }
  }

  Future<int> createExercise(Exercise exercise) async {
    try {
      return await insert('exercises', exercise.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createExercise',
      );

      return -1;
    }
  }

  Future<int> createMultiset(Multiset multiset) async {
    try {
      return await insert('multisets', multiset.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createMultiset',
      );

      return -1;
    }
  }

  Future<int> createTraining(Training training) async {
    try {
      // Insert training
      final trainingId = await insert('trainings', training.toMap());

      final List<Multiset> newMultisets = [];
      final List<Exercise> newExercises = [];

      // Insert multisets
      for (var multiset in training.multisets) {
        final multisetWithTrainingId =
            multiset.copyWith(trainingId: trainingId);
        final multisetId =
            await insert('multisets', multisetWithTrainingId.toMap());
        newMultisets
            .add(multiset.copyWith(id: multisetId, trainingId: trainingId));

        // Insert multiset exercises
        final matchingExercises = training.exercises
            .where((e) => e.multisetKey == multiset.widgetKey)
            .toList();

        for (var exercise in matchingExercises) {
          final exerciseWithMultisetId =
              exercise.copyWith(trainingId: trainingId, multisetId: multisetId);
          final exerciseId =
              await insert('exercises', exerciseWithMultisetId.toMap());
          newExercises.add(exercise.copyWith(
              id: exerciseId, trainingId: trainingId, multisetId: multisetId));
        }
      }

      final exercisesWithoutMultiset =
          training.exercises.where((e) => e.multisetKey == null).toList();

      // Insert exercises not linked to a multiset
      for (var exercise in exercisesWithoutMultiset) {
        final exerciseWithTrainingId =
            exercise.copyWith(trainingId: trainingId);
        final exerciseId =
            await insert('exercises', exerciseWithTrainingId.toMap());
        newExercises
            .add(exercise.copyWith(id: exerciseId, trainingId: trainingId));
      }

      final TrainingVersion trainingVersion = TrainingVersion.fromTraining(
          trainingId: trainingId,
          training: training.copyWith(
              id: trainingId,
              multisets: newMultisets,
              exercises: newExercises));
      await createTrainingVersion(trainingVersion);

      return trainingId;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createTraining',
      );

      return -1;
    }
  }

  Future<int> createTrainingVersion(TrainingVersion trainingVersion) async {
    try {
      await _db.execute(
          '''DELETE FROM training_versions WHERE trainingId = ? AND id NOT IN (
      SELECT DISTINCT trainingVersionId FROM history_entries
      UNION
      SELECT DISTINCT trainingVersionId FROM run_locations
    )''', [trainingVersion.trainingId]);
      return await insert('training_versions', trainingVersion.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createTrainingVersion',
      );

      return -1;
    }
  }

  Future<void> createHistoryEntry(HistoryEntry historyEntry) async {
    try {
      await insert('history_entries', historyEntry.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createHistoryEntry',
      );
    }
  }

  Future<void> createRunLocation(RunLocation runLocation) async {
    try {
      await insert('run_locations', runLocation.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createRunLocation',
      );
    }
  }

  Future<void> createReminder(Reminder reminder) async {
    try {
      await insert('reminders', reminder.toMap());
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'createReminder',
      );
    }
  }

  Future<void> savePreferences(bool isReminderActive) async {
    try {
      // Supprime tout enregistrement pour maintenir une seule préférence.
      await _db.execute('DELETE FROM preferences');

      await insert(
          'preferences', {'isReminderActive': isReminderActive ? 1 : 0});
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'savePreferences',
      );
    }
  }

  //! Read operations

  Future<List<Log>> getAllLogs() async {
    try {
      final result = await _db.execute('SELECT * from logs ORDER BY date DESC');
      if (result.isEmpty) return [];
      return result.map((row) => Log.fromMap(row)).toList();
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getAllLogs',
      );
      return [];
    }
  }

  Future<BaseExercise?> getBaseExerciseById(int baseExerciseId) async {
    try {
      final List<Map<String, dynamic>> result = await _db.getAll(
          'SELECT * FROM base_exercises WHERE id = ?', [baseExerciseId]);

      if (result.isEmpty) return null;
      final baseExercise = BaseExercise.fromMap(result.first);

      return baseExercise;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getBaseExerciseById',
      );

      return null;
    }
  }

  Future<List<BaseExercise>> getAllBaseExercises() async {
    try {
      final List<Map<String, dynamic>> result =
          await _db.getAll('SELECT * FROM base_exercises');

      final List<BaseExercise> baseExercises =
          result.map((row) => BaseExercise.fromMap(row)).toList();

      return baseExercises;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getAllBaseExercises',
      );
      return [];
    }
  }

  Future<List<TrainingVersion>> getAllTrainingVersions() async {
    try {
      final List<Map<String, dynamic>> result =
          await _db.getAll('SELECT * FROM training_versions');

      final List<TrainingVersion> trainingVersions =
          result.map((row) => TrainingVersion.fromMap(row)).toList();

      return trainingVersions;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getAllTrainingVersions',
      );
      return [];
    }
  }

  Future<Training?> getTrainingById(int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db
          .getAll('SELECT * FROM trainings WHERE id = ?', [trainingId]);

      if (result.isEmpty) return null;
      Training training = Training.fromMap(result.first);

      final multisets = await getMultisetsByTrainingId(training.id!);

      final exercises = await getExercisesByTrainingId(training.id!);

      List<BaseExercise> baseExercises = [];

      for (var exercise in exercises) {
        if (exercise.baseExerciseId != null) {
          final baseExercise =
              await getBaseExerciseById(exercise.baseExerciseId!);
          baseExercises.add(baseExercise!);
        }
      }

      training = training.copyWith(
        multisets: multisets,
        exercises: exercises,
        baseExercises: baseExercises,
      );

      return training;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getTrainingById',
      );
      return null;
    }
  }

  Future<List<Training>> getAllTrainings() async {
    try {
      final List<Map<String, dynamic>> trainingsResult =
          await _db.getAll('SELECT * FROM trainings');

      final List<Training> trainings = [];

      for (var row in trainingsResult) {
        final training = Training.fromMap(row);

        final multisets = await getMultisetsByTrainingId(training.id!);

        final exercises = await getExercisesByTrainingId(training.id!);

        List<BaseExercise> baseExercises = [];

        for (var exercise in exercises) {
          if (exercise.baseExerciseId != null) {
            final baseExercise =
                await getBaseExerciseById(exercise.baseExerciseId!);
            baseExercises.add(baseExercise!);
          }
        }

        trainings.add(
          training.copyWith(
            multisets: multisets,
            exercises: exercises,
            baseExercises: baseExercises,
          ),
        );
      }

      return trainings;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getAllTrainings',
      );
      return [];
    }
  }

  Future<List<Multiset>> getMultisetsByTrainingId(int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db
          .getAll('SELECT * FROM multisets WHERE trainingId = ?', [trainingId]);

      if (result.isEmpty) return [];

      final List<Multiset> multisets =
          result.map((row) => Multiset.fromMap(row)).toList();

      return multisets;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getMultisetsByTrainingId',
      );
      return [];
    }
  }

  Future<List<Exercise>> getExercisesByTrainingId(int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db
          .getAll('SELECT * FROM exercises WHERE trainingId = ?', [trainingId]);

      if (result.isEmpty) return [];

      final List<Exercise> exercises =
          result.map((row) => Exercise.fromMap(row)).toList();

      return exercises;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getExercisesByTrainingId',
      );
      return [];
    }
  }

  Future<List<HistoryEntry>> getHistoryEntriesByTrainingId(
      int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db.getAll(
          'SELECT * FROM history_entries WHERE trainingId = ?', [trainingId]);

      final List<HistoryEntry> historyEntries =
          result.map((row) => HistoryEntry.fromMap(row)).toList();

      return historyEntries;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getHistoryEntriesByTrainingId',
      );
      return [];
    }
  }

  Future<Map<int, int?>> getDaysSinceTraining() async {
    try {
      Map<int, int?> daysSinceTrainings = {};

      final trainings = await getAllTrainings();

      for (var training in trainings) {
        final allEntries = await getHistoryEntriesByTrainingId(training.id!);
        final lastEntry = allEntries.isNotEmpty ? allEntries.last : null;

        if (lastEntry != null) {
          final date = lastEntry.date;
          final now = DateTime.now();
          final differenceInDays = now.difference(date).inDays;

          // Ajouter la valeur à la map
          daysSinceTrainings[training.id!] = differenceInDays;
        } else {
          // Si aucun résultat n'existe pour le training, on met `null` dans la map
          daysSinceTrainings[training.id!] = null;
        }
      }

      return daysSinceTrainings;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getDaysSinceTraining',
      );
      return {};
    }
  }

  Future<Training?> getTrainingByVersionId(int versionId) async {
    try {
      final List<Map<String, dynamic>> result = await _db
          .getAll('SELECT * FROM training_versions WHERE id = ?', [versionId]);

      if (result.isEmpty) return null;

      final trainingVersion = TrainingVersion.fromMap(result.first);
      final training = trainingVersion.fullTraining;

      return training;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getFullTrainingByVersionId',
      );
      return null;
    }
  }

  Future<TrainingVersion?> getMostRecentTrainingVersionForTrainingId(
      int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db.getAll(
          'SELECT * FROM training_versions WHERE trainingId = ?', [trainingId]);

      if (result.isEmpty) return null;

      final TrainingVersion trainingVersion =
          TrainingVersion.fromMap(result.last);

      return trainingVersion;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getMostRecentTrainingVersionForTrainingId',
      );
      return null;
    }
  }

  Future<List<HistoryEntry>> getFilteredHistoryEntries({
    required DateTime startDate,
    required DateTime endDate,
    required List<TrainingType>? trainingTypes,
    required int? baseExerciseId,
    required int? trainingId,
  }) async {
    try {
      // On construit la clause WHERE
      // On utilise un StringBuffer pour concaténer les conditions
      final whereClause = StringBuffer();
      // Liste des paramètres à l'ordre des '?' dans la requête
      final List<Object?> params = [];

      // Filtre sur la date
      whereClause.write('he.date BETWEEN ? AND ?');
      params.addAll([
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ]);

      // Si on fournit une liste de trainingTypes (et qu'elle n'est pas vide)
      if (trainingTypes != null && trainingTypes.isNotEmpty) {
        // Pour plusieurs valeurs, on utilise l'opérateur IN
        final placeholders =
            List.generate(trainingTypes.length, (_) => '?').join(', ');
        whereClause.write(' AND t.trainingType IN ($placeholders)');
        // On ajoute les valeurs dans la liste de paramètres, par exemple en utilisant toString()
        params.addAll(trainingTypes.map((type) => type.toMap()));
      }

      // Si un baseExerciseId est fourni, on rejoint la table exercises.
      if (baseExerciseId != null) {
        whereClause.write(' AND e.baseExerciseId = ?');
        params.add(baseExerciseId);
      }

      // Si un trainingId est fourni, on filtre directement sur la table history_entries.
      if (trainingId != null) {
        whereClause.write(' AND he.trainingId = ?');
        params.add(trainingId);
      }

      // Construction de la requête SQL avec les jointures nécessaires :
      // - Pour trainingType : join sur la table trainings.
      // - Pour baseExerciseId : join sur la table exercises.
      final query = '''
      SELECT he.*
      FROM history_entries AS he
      LEFT JOIN trainings AS t ON he.trainingId = t.id
      LEFT JOIN exercises AS e ON he.exerciseId = e.id
      WHERE ${whereClause.toString()}
      ORDER BY he.date ASC
    ''';

      // Exécution de la requête :
      final results = await _db.execute(query, params);

      return results.map((row) => HistoryEntry.fromMap(row)).toList();
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getFilteredHistoryEntries',
      );
      return [];
    }
  }

  Future<List<RunLocation>> getFilteredRunLocations({
    required DateTime startDate,
    required DateTime endDate,
    required List<TrainingType>? trainingTypes,
    required int? baseExerciseId,
    required int? trainingId,
  }) async {
    try {
      // Construction dynamique de la clause WHERE
      final whereClause = StringBuffer();
      final List<Object?> params = [];

      // Filtrage sur la date (on suppose ici que la date est stockée en millisecondes)
      whereClause.write('rl.date BETWEEN ? AND ?');
      params.addAll([
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ]);

      // Si une liste de trainingTypes est fournie et non vide, on ajoute la condition avec IN
      if (trainingTypes != null && trainingTypes.isNotEmpty) {
        final placeholders =
            List.generate(trainingTypes.length, (_) => '?').join(', ');
        whereClause.write(' AND t.trainingType IN ($placeholders)');
        params.addAll(trainingTypes.map((type) => type.toString()));
      }

      // Si un baseExerciseId est fourni, on filtre via la table exercises
      if (baseExerciseId != null) {
        whereClause.write(' AND e.baseExerciseId = ?');
        params.add(baseExerciseId);
      }

      // Si un trainingId est fourni, on filtre directement sur la table run_locations
      if (trainingId != null) {
        whereClause.write(' AND rl.trainingId = ?');
        params.add(trainingId);
      }

      // Construction de la requête SQL avec jointures pour accéder aux informations de trainings et exercises :
      final query = '''
      SELECT rl.*
      FROM run_locations AS rl
      LEFT JOIN trainings AS t ON rl.trainingId = t.id
      LEFT JOIN exercises AS e ON rl.exerciseId = e.id
      WHERE ${whereClause.toString()}
      ORDER BY rl.date ASC
    ''';

      // Exécution de la requête avec les paramètres liés :
      final results = await _db.execute(query, params);

      // Conversion des résultats en objets RunLocation
      return results.map((row) => RunLocation.fromMap(row)).toList();
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getFilteredRunLocations',
      );
      return [];
    }
  }

  Future<int?> getRegisteredHistoryEntryId({
    required int exerciseId,
    required int setNumber,
    required int trainingId,
  }) async {
    try {
      // Construction de la requête SQL avec un LIMIT pour ne retourner qu'une seule ligne
      const query = '''
      SELECT id 
      FROM history_entries 
      WHERE exerciseId = ? 
        AND setNumber = ? 
        AND trainingId = ?
      LIMIT 1
    ''';

      // Exécution de la requête avec les paramètres liés
      final results =
          await _db.execute(query, [exerciseId, setNumber, trainingId]);

      // Si un résultat est trouvé, on retourne son id
      if (results.isNotEmpty) {
        return results.first['id'] as int;
      }

      // Aucune entrée trouvée
      return null;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getRegisteredHistoryEntryId',
      );
      return null;
    }
  }

  Future<DateTime?> getLastEntryDate(int trainingVersionId) async {
    try {
      final result = await _db.execute(
        'SELECT * FROM history_entries WHERE trainingVersionId = ? LIMIT 1',
        [trainingVersionId],
      );

      if (result.isEmpty) return null;

      return DateTime.fromMillisecondsSinceEpoch(result.first['date'] as int);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getLastEntryDate',
      );
      return null;
    }
  }

  Future<bool?> checkIfTrainingHasRecentEntry(int exerciseId) async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      final result = await _db.execute(
        'SELECT 1 FROM history_entries WHERE date > ? AND exerciseId = ? LIMIT 1',
        [twoHoursAgo.millisecondsSinceEpoch, exerciseId],
      );

      return result.isNotEmpty;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'checkIfTrainingHasRecentEntry',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final List<Map<String, dynamic>> result =
          await _db.getAll('SELECT * FROM preferences');

      if (result.isEmpty) return null;

      return {
        'isReminderActive':
            result.first['isReminderActive'] == 1, // Convertir entier en bool
      };
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getPreferences',
      );
      return null;
    }
  }

  Future<List<Reminder>> getAllReminders() async {
    try {
      final List<Map<String, dynamic>> result =
          await _db.getAll('SELECT * FROM reminders');

      final List<Reminder> reminders =
          result.map((row) => Reminder.fromMap(row)).toList();

      return reminders;
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'getAllReminders',
      );
      return [];
    }
  }

  //! Update operations

  Future<void> updateBaseExercise(BaseExercise baseExercise) async {
    try {
      await update(
          'base_exercises', baseExercise.toMap(), 'id = ?', [baseExercise.id!]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'updateBaseExercise',
      );
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      await update('exercises', exercise.toMap(), 'id = ?', [exercise.id!]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'updateExercise',
      );
    }
  }

  Future<void> updateMultiset(Multiset multiset) async {
    try {
      await update('multisets', multiset.toMap(), 'id = ?', [multiset.id!]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'updateMultiset',
      );
    }
  }

  Future<void> updateTraining(Training training) async {
    try {
      // Update the main training table
      await update('trainings', training.toMap(), 'id = ?', [training.id]);

      final List<Multiset> newMultisets = [];
      final List<Exercise> newExercises = [];

      // Récupérer l'ensemble des multisets existants pour cet entraînement
      final existingMultisets = await getMultisetsByTrainingId(training.id!);

      // Récupérer tous les exercices existants pour cet entraînement
      final existingExercises = await getExercisesByTrainingId(training.id!);

      // Mettre à jour ou insérer chaque multiset
      for (var multiset in training.multisets) {
        if (existingMultisets.any((m) => m.id == multiset.id)) {
          // Cas mise à jour
          await update(
            'multisets',
            multiset.toMap(),
            'id = ?',
            [multiset.id],
          );
          newMultisets.add(multiset);

          // Ajouter ou mettre à jour les exercises associés à ce multiset
          final matchingExercises = training.exercises
              .where((e) => e.multisetKey == multiset.widgetKey)
              .toList();

          for (var exercise in matchingExercises) {
            if (exercise.id != null &&
                existingExercises.any((e) => e.id == exercise.id)) {
              // Cas mise à jour
              await update(
                'exercises',
                exercise.toMap(),
                'id = ?',
                [exercise.id],
              );
              newExercises.add(exercise);
            } else {
              // Cas ajout (nouvel exercice)
              final exerciseId = await insert(
                'exercises',
                exercise
                    .copyWith(trainingId: training.id, multisetId: multiset.id)
                    .toMap(),
              );
              newExercises.add(exercise.copyWith(
                  id: exerciseId,
                  trainingId: training.id,
                  multisetId: multiset.id));
            }
          }
        } else {
          // Cas ajout (nouveau multiset)
          final multisetWithTrainingId =
              multiset.copyWith(trainingId: training.id);
          final multisetId =
              await insert('multisets', multisetWithTrainingId.toMap());
          newMultisets
              .add(multiset.copyWith(id: multisetId, trainingId: training.id));

          // Ajout des exercices associés à ce multiset
          final matchingExercises = training.exercises
              .where((e) => e.multisetKey == multiset.widgetKey)
              .toList();

          for (var exercise in matchingExercises) {
            final exerciseWithMultisetId = exercise.copyWith(
                trainingId: training.id, multisetId: multisetId);
            final exerciseId =
                await insert('exercises', exerciseWithMultisetId.toMap());
            newExercises.add(exercise.copyWith(
                id: exerciseId,
                trainingId: training.id,
                multisetId: multiset.id));
          }
        }
      }

      // Supprimer les multisets qui ne sont plus dans `training.multisets`
      final multisetIdsToKeep =
          training.multisets.map((m) => m.id).whereType<int>().toList();
      final multisetIdsToDelete =
          existingMultisets.where((m) => !multisetIdsToKeep.contains(m.id));

      for (var multisetToDelete in multisetIdsToDelete) {
        await deleteMultiset(multisetToDelete.id!);
      }

      final exercisesWithoutMultisets =
          training.exercises.where((e) => e.multisetKey == null).toList();

      // Mettre à jour, insérer ou supprimer les exercices liés non associés à des multisets
      for (var exercise in exercisesWithoutMultisets) {
        if (exercise.id != null &&
            existingExercises.any((e) => e.id == exercise.id)) {
          // Cas mise à jour
          await update(
            'exercises',
            exercise.toMap(),
            'id = ?',
            [exercise.id],
          );
          newExercises.add(exercise);
        } else {
          // Cas ajout (nouvel exercice)
          final exerciseId = await insert(
              'exercises', exercise.copyWith(trainingId: training.id).toMap());
          newExercises
              .add(exercise.copyWith(id: exerciseId, trainingId: training.id));
        }
      }

      // Supprimer les exercices qui ne sont plus dans `training.exercises`
      final exerciseIdsToKeep =
          training.exercises.map((e) => e.id).whereType<int>().toList();
      final exercisesToDelete =
          existingExercises.where((e) => !exerciseIdsToKeep.contains(e.id));

      for (var exerciseToDelete in exercisesToDelete) {
        await deleteExercise(exerciseToDelete.id!);
      }

      final TrainingVersion trainingVersion = TrainingVersion.fromTraining(
        trainingId: training.id!,
        training:
            training.copyWith(multisets: newMultisets, exercises: newExercises),
      );
      await createTrainingVersion(trainingVersion);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'updateTraining',
      );
    }
  }

  Future<void> updateHistoryEntry(HistoryEntry historyEntry) async {
    try {
      await update('history_entries', historyEntry.toMap(), 'id = ?',
          [historyEntry.id!]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'updateHistoryEntry',
      );
    }
  }

  //! Delete operations

  Future<void> deleteBaseExercise(int baseExerciseId) async {
    try {
      await _db
          .execute('DELETE FROM base_exercises WHERE id = ?', [baseExerciseId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteBaseExercise',
      );
    }
  }

  Future<void> deleteExercise(int exerciseId) async {
    try {
      await _db.execute('DELETE FROM exercises WHERE id = ?', [exerciseId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteExercise',
      );
    }
  }

  Future<void> deleteMultiset(int multisetId) async {
    try {
      await _db
          .execute('DELETE FROM exercises WHERE multisetId = ?', [multisetId]);
      await _db.execute('DELETE FROM multisets WHERE id = ?', [multisetId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteMultiset',
      );
    }
  }

  Future<void> deleteTraining(int trainingId) async {
    try {
      await _db
          .execute('DELETE FROM exercises WHERE trainingId = ?', [trainingId]);
      await _db
          .execute('DELETE FROM multisets WHERE trainingId = ?', [trainingId]);
      await _db.execute('DELETE FROM trainings WHERE id = ?', [trainingId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteTraining',
      );
    }
  }

  Future<void> deleteHistoryEntry(int historyEntryId) async {
    try {
      await _db.execute(
          'DELETE FROM history_entries WHERE id = ?', [historyEntryId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteHistoryEntry',
      );
    }
  }

  Future<void> deleteHistoryTraining(HistoryTraining historyTraining) async {
    try {
      for (var entry in historyTraining.historyEntries) {
        await _db
            .execute('DELETE FROM history_entries WHERE id = ?', [entry.id]);
      }
      for (var location in historyTraining.locations) {
        await _db
            .execute('DELETE FROM run_locations WHERE id = ?', [location.id]);
      }
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteHistoryEntriesByTrainingId',
      );
    }
  }

  Future<void> deleteReminder(int notificationId) async {
    try {
      await _db.execute(
          'DELETE FROM reminders WHERE notificationId = ?', [notificationId]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteReminder',
      );
    }
  }

  Future<void> deleteOldLogs() async {
    try {
      final int thirtyDaysAgo =
          DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch;
      await _db.execute('DELETE FROM logs WHERE date < ?', [thirtyDaysAgo]);
    } catch (e) {
      showToastMessage(
        message: e.toString(),
        isSuccess: false,
        isLog: true,
        logLevel: LogLevel.error,
        logFunction: 'deleteOldLogs',
      );
    }
  }
}
