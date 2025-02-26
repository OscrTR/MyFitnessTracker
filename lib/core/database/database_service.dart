import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/models/reminder.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/base_exercise_management/models/base_exercise.dart';
import '../../features/training_history/models/history_entry.dart';
import '../../features/training_history/models/history_run_location.dart';
import '../../features/training_management/models/multiset.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../features/training_history/models/training_version.dart';
import '../../features/training_management/models/exercise.dart';
import '../../features/training_management/models/training.dart';
import '../../injection_container.dart';

class DatabaseService {
  late final SqliteDatabase _db;

  final migrations = SqliteMigrations()
    ..add(SqliteMigration(1, (tx) async {
      await tx.execute('''
  CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    notificationId INTEGER NOT NULL,
    day INTEGER NOT NULL
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
    targetPace INTEGER NOT NULL,
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
    pace INTEGER NOT NULL,
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
    speed REAL NOT NULL,
    FOREIGN KEY (trainingId) REFERENCES trainings (id),
    FOREIGN KEY (exerciseId) REFERENCES exercises (id),
    FOREIGN KEY (trainingVersionId) REFERENCES training_versions (id)
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
    }));

  Future<void> performMaintenance() async {
    try {
      await _db.execute("VACUUM;");
      await _db.execute("ANALYZE;");
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  String generateInsertSQL(String tableName, Map<String, dynamic> map) {
    final columns = map.keys.join(', ');
    final placeholders = map.keys.map((_) => '?').join(', ');
    return 'INSERT INTO $tableName ($columns) VALUES ($placeholders)';
  }

  Future<int> insert(String tableName, Map<String, dynamic> fields) async {
    try {
      // Exclut "id" car auto incrémenté
      final cleanFields = Map.of(fields)..remove('id');

      final sql = generateInsertSQL(tableName, cleanFields);
      await _db.execute(sql, cleanFields.values.toList());
      final result = await _db.execute('SELECT last_insert_rowid()');
      return result.first.values.first as int;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      // Exclut "id" car auto incrémenté
      final cleanFields = Map.of(fields)..remove('id');

      final sql = generateUpdateSQL(tableName, cleanFields, whereClause);
      final allArgs = [...cleanFields.values, ...whereArgs];
      await _db.execute(sql, allArgs);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  //! Create operations

  Future<int> createBaseExercise(BaseExercise baseExercise) async {
    try {
      return await insert('base_exercises', baseExercise.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return -1;
    }
  }

  Future<int> createExercise(Exercise exercise) async {
    try {
      return await insert('exercises', exercise.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return -1;
    }
  }

  Future<int> createMultiset(Multiset multiset) async {
    try {
      return await insert('multisets', multiset.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return -1;
    }
  }

  Future<int> createTrainingVersion(TrainingVersion trainingVersion) async {
    try {
      await _db.execute('''DELETE FROM training_versions WHERE id NOT IN (
      SELECT DISTINCT trainingVersionId FROM history_entries
      UNION
      SELECT DISTINCT trainingVersionId FROM run_locations
    )''');
      return await insert('training_versions', trainingVersion.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return -1;
    }
  }

  Future<void> createHistoryEntry(HistoryEntry historyEntry) async {
    try {
      await insert('history_entries', historyEntry.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> createRunLocation(RunLocation runLocation) async {
    try {
      await insert('run_locations', runLocation.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> createReminder(Reminder reminder) async {
    try {
      await insert('reminders', reminder.toMap());
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> savePreferences(bool isReminderActive) async {
    try {
      // Supprime tout enregistrement pour maintenir une seule préférence.
      await _db.execute('DELETE FROM preferences');

      await insert(
          'preferences', {'isReminderActive': isReminderActive ? 1 : 0});
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  //! Read operations

  Future<BaseExercise?> getBaseExerciseById(int baseExerciseId) async {
    try {
      final Map<String, dynamic> result = await _db
          .get('SELECT * FROM base_exercises WHERE id = ?', [baseExerciseId]);

      if (result.isEmpty) return null;
      final baseExercise = BaseExercise.fromMap(result);

      return baseExercise;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return [];
    }
  }

  Future<Training?> getTrainingById(int trainingId) async {
    try {
      final Map<String, dynamic> result =
          await _db.get('SELECT * FROM trainings WHERE id = ?', [trainingId]);

      Training training = Training.fromMap(result);

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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return {};
    }
  }

  Future<Training?> getBaseTrainingByVersionId(int versionId) async {
    try {
      final Map<String, dynamic> result = await _db
          .get('SELECT * FROM training_versions WHERE id = ?', [versionId]);

      final trainingVersion = TrainingVersion.fromMap(result);
      final training = trainingVersion.training;

      return training;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return null;
    }
  }

  Future<Training?> getFullTrainingByVersionId(int versionId) async {
    try {
      final Map<String, dynamic> result = await _db
          .get('SELECT * FROM training_versions WHERE id = ?', [versionId]);

      final trainingVersion = TrainingVersion.fromMap(result);
      final training = trainingVersion.fullTraining;

      return training;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return null;
    }
  }

  Future<TrainingVersion?> getMostRecentTrainingVersionForTrainingId(
      int trainingId) async {
    try {
      final List<Map<String, dynamic>> result = await _db.getAll(
          'SELECT * FROM training_versions WHERE trainingId = ?', [trainingId]);

      final TrainingVersion trainingVersion =
          TrainingVersion.fromMap(result.last);

      return trainingVersion;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return null;
    }
  }

  Future<List<HistoryEntry>> getHistoryEntriesForPeriod(
      DateTime startDate, DateTime endDate) async {
    try {
      final results = await _db.execute(
        'SELECT * FROM history_entries WHERE date BETWEEN ? AND ?',
        [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      );

      return results.map((row) => HistoryEntry.fromMap(row)).toList();
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return [];
    }
  }

  Future<List<RunLocation>> getRunLocationsForPeriod(
      DateTime startDate, DateTime endDate) async {
    try {
      final results = await _db.execute(
        'SELECT * FROM run_locations WHERE date BETWEEN ? AND ?',
        [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      );

      return results.map((row) => RunLocation.fromMap(row)).toList();
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return [];
    }
  }

  Future<bool?> checkIfTrainingHasRecentEntry(int exerciseId) async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      final result = await _db.execute(
        'SELECT 1 FROM history_entries WHERE date > ? AND trainingId = ? LIMIT 1',
        [twoHoursAgo.millisecondsSinceEpoch, exerciseId],
      );

      return result.isNotEmpty;
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final Map<String, dynamic> result =
          await _db.get('SELECT * FROM preferences');

      return {
        'isReminderActive':
            result['isReminderActive'] == 1, // Convertir entier en bool
      };
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
      return [];
    }
  }

  //! Update operations

  Future<void> updateBaseExercise(BaseExercise baseExercise) async {
    try {
      await update(
          'base_exercises', baseExercise.toMap(), 'id = ?', [baseExercise.id!]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      await update('exercises', exercise.toMap(), 'id = ?', [exercise.id!]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> updateMultiset(Multiset multiset) async {
    try {
      await update('multisets', multiset.toMap(), 'id = ?', [multiset.id!]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> updateHistoryEntry(HistoryEntry historyEntry) async {
    try {
      await update('history_entries', historyEntry.toMap(), 'id = ?',
          [historyEntry.id!]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  //! Delete operations

  Future<void> deleteBaseExercise(int baseExerciseId) async {
    try {
      await _db
          .execute('DELETE FROM base_exercises WHERE id = ?', [baseExerciseId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> deleteExercise(int exerciseId) async {
    try {
      await _db.execute('DELETE FROM exercises WHERE id = ?', [exerciseId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> deleteMultiset(int multisetId) async {
    try {
      await _db
          .execute('DELETE FROM exercises WHERE multisetId = ?', [multisetId]);
      await _db.execute('DELETE FROM multisets WHERE id = ?', [multisetId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
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
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> deleteHistoryEntry(int historyEntryId) async {
    try {
      await _db.execute(
          'DELETE FROM history_entries WHERE id = ?', [historyEntryId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> deleteHistoryEntriesByTrainingId(int trainingId) async {
    try {
      await _db.execute(
          'DELETE FROM history_entries WHERE trainingId = ?', [trainingId]);
      await _db.execute(
          'DELETE FROM run_locations WHERE trainingId = ?', [trainingId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }

  Future<void> deleteReminder(int notificationId) async {
    try {
      await _db.execute(
          'DELETE FROM reminders WHERE notificationId = ?', [notificationId]);
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(
          message: 'Database error : ${e.toString()}', isError: true));
    }
  }
}
