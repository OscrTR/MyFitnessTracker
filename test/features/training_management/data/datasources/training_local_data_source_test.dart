import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/models/exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/training_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late SQLiteTrainingLocalDataSource dataSource;
  late SQLiteExerciseLocalDataSource exerciseLocalDataSource;
  late Database db;

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await _createTables(db);
    dataSource = SQLiteTrainingLocalDataSource(database: db);
    exerciseLocalDataSource = SQLiteExerciseLocalDataSource(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  const exercise = ExerciseModel(
      id: null,
      name: 'Downward Dog',
      description: 'Awesome description',
      imagePath: 'pathToImage');

  const trainingExercise = TrainingExerciseModel(
    id: null,
    trainingId: null,
    multisetId: null,
    exerciseId: 1,
    trainingExerciseType: TrainingExerciseType.yoga,
    sets: 3,
    reps: 15,
    duration: 600,
    setRest: 120,
    exerciseRest: 90,
    manualStart: true,
    targetDistance: 5000,
    targetDuration: 1800,
    targetRythm: 80,
    intervals: 5,
    intervalDistance: 1000,
    intervalDuration: 300,
    intervalRest: 60,
    specialInstructions: '',
    objectives: '',
  );

  const multiset = MultisetModel(
    id: null,
    trainingId: null,
    sets: 4,
    setRest: 60,
    multisetRest: 120,
    specialInstructions: 'Do it slowly',
    objectives: 'Increase strength',
    trainingExercises: [trainingExercise],
  );

  const training = TrainingModel(
    id: null,
    name: 'Full Body Workout',
    type: TrainingType.yoga,
    isSelected: true,
    multisets: [multiset],
    trainingExercises: [trainingExercise],
  );

  final trainingJson = {
    'id': 1,
    'name': 'Full Body Workout',
    'type': 1,
    'is_selected': 1,
    'multisets': [
      {
        'id': 1,
        'training_id': 1,
        'training_exercises': [
          {
            "id": 1,
            "training_id": 1,
            "multiset_id": 1,
            "exercise_id": 1,
            "name": "Downward Dog",
            "description": "Awesome description",
            "imagePath": "pathToImage",
            "training_exercise_type": 1,
            "special_instructions": "",
            "objectives": "",
            "target_distance": 5000,
            "target_duration": 1800,
            "target_rythm": 80,
            "intervals": 5,
            "interval_distance": 1000,
            "interval_duration": 300,
            "interval_rest": 60,
            "sets": 3,
            "reps": 15,
            "duration": 600,
            "set_rest": 120,
            "exercise_rest": 90,
            "manual_start": 1
          }
        ],
        'sets': 4,
        'set_rest': 60,
        'multiset_rest': 120,
        'special_instructions': 'Do it slowly',
        'objectives': 'Increase strength',
      }
    ],
    'training_exercises': [
      {
        "id": 2,
        "training_id": 1,
        "multiset_id": null,
        "exercise_id": 1,
        "name": "Downward Dog",
        "description": "Awesome description",
        "imagePath": "pathToImage",
        "training_exercise_type": 1,
        "special_instructions": "",
        "objectives": "",
        "target_distance": 5000,
        "target_duration": 1800,
        "target_rythm": 80,
        "intervals": 5,
        "interval_distance": 1000,
        "interval_duration": 300,
        "interval_rest": 60,
        "sets": 3,
        "reps": 15,
        "duration": 600,
        "set_rest": 120,
        "exercise_rest": 90,
        "manual_start": 1
      }
    ]
  };

  group('create training', () {
    test(
      'should insert a training, its multisets, and associated training exercises',
      () async {
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));
      },
    );
  });
}

Future<void> _createTables(Database db) async {
  await db.execute('''
    CREATE TABLE exercises(
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      name TEXT, 
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
      reps INTEGER,
      duration INTEGER,
      set_rest INTEGER,
      exercise_rest INTEGER,
      manual_start INTEGER,
      target_distance INTEGER,
      target_duration INTEGER,
      target_rythm INTEGER,
      intervals INTEGER,
      interval_distance INTEGER,
      interval_duration INTEGER,
      interval_rest INTEGER,
      special_instructions TEXT,
      objectives TEXT,
      FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE,
      FOREIGN KEY(multiset_id) REFERENCES multisets(id) ON DELETE CASCADE,
      FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    )
  ''');
}
