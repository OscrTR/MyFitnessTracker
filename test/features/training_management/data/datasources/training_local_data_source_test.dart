import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/training_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_fitness_tracker/features/exercise_management/data/models/exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

const exercise = ExerciseModel(
    id: null,
    name: 'Downward Dog',
    description: 'Awesome description',
    imagePath: 'pathToImage');

const exerciseJson = {
  'id': 1,
  'name': 'Downward Dog',
  'description': 'Awesome description',
  'image_path': 'pathToImage'
};

final trainingExerciseBase = createTrainingExercise();

final multisetBase = createMultiset(
  trainingExercises: [trainingExerciseBase],
);

final trainingBase = createTraining(
  multisets: [multisetBase],
  trainingExercises: [trainingExerciseBase],
);

final trainingBaseJson = {
  'id': 1,
  'name': 'Full Body Workout',
  'type': 1,
  'is_selected': 1,
  'multisets': [
    {
      'id': 1,
      'training_id': 1,
      'training_exercises': [
        createTrainingExercise(id: 1, trainingId: 1, multisetId: 1).toJson(),
      ],
      'sets': 4,
      'set_rest': 60,
      'multiset_rest': 120,
      'special_instructions': 'Do it slowly',
      'objectives': 'Increase strength',
    }
  ],
  'training_exercises': [
    createTrainingExercise(id: 2, trainingId: 1).toJson(),
  ]
};

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

  group('create and get training', () {
    test(
      'should insert a training, its multisets, and associated training exercises then get the training and all the associated info',
      () async {
        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Act : create the training
        final trainingResult = await dataSource.createTraining(trainingBase);
        expect(trainingResult.name, trainingBase.name);
        expect(trainingResult.id, isNotNull);

        // Assert : get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingBaseJson));
      },
    );
  });

  group('fetch trainings', () {
    test(
      'should retrieve all the trainings with their minimal info (no multisets/training exercises)',
      () async {
        // Arrange
        final fetchTrainingsMatcher = createTraining(id: 1);
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Assert : fetch all trainings and compare the result to what's expected
        final result = await dataSource.fetchTrainings();
        expect(result, [fetchTrainingsMatcher]);
      },
    );
  });

  group('update training', () {
    final trainingExerciseUpdated = createTrainingExercise(
        id: 2, trainingId: 1, specialInstructions: 'EDITED');

    final multisetTrainingExerciseUpdated = createTrainingExercise(
      id: 1,
      trainingId: 1,
      multisetId: 1,
      specialInstructions: 'EDITED',
    );

    final multisetUpdated = createMultiset(
      id: 1,
      trainingId: 1,
      trainingExercises: [multisetTrainingExerciseUpdated],
    );

    final trainingUpdate = createTraining(
      id: 1,
      name: 'EDITED Full Body Workout',
      type: TrainingType.run,
      isSelected: false,
      multisets: [multisetUpdated],
      trainingExercises: [trainingExerciseUpdated],
    );

    test(
      'UPDATE 1 : should update the training, its multisets and its training exercises',
      () async {
        // Arrange
        final trainingUpdatedJson = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [
            {
              'id': 1,
              'training_id': 1,
              'training_exercises': [
                createTrainingExercise(
                        id: 1,
                        trainingId: 1,
                        multisetId: 1,
                        specialInstructions: 'EDITED')
                    .toJson(),
              ],
              'sets': 4,
              'set_rest': 60,
              'multiset_rest': 120,
              'special_instructions': 'Do it slowly',
              'objectives': 'Increase strength',
            }
          ],
          'training_exercises': [
            createTrainingExercise(
                    id: 2, trainingId: 1, specialInstructions: 'EDITED')
                .toJson(),
          ]
        };

        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : update the training
        await dataSource.updateTraining(trainingUpdate);

        // Assert : compare the updated training to what's exepected
        final updatedTraining = await dataSource.getTraining(1);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdatedJson));

        await _verifyDatabase(db: db, multisetsListMatcher: [
          multisetUpdated.toJson()
        ], trainingExercisesListMatcher: [
          multisetTrainingExerciseUpdated.toJson(),
          trainingExerciseUpdated.toJson()
        ]);
      },
    );

    test(
      'UPDATE 2 : should update the training and delete the training exercises',
      () async {
        // Arrange
        final trainingUpdate2Json = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [
            {
              'id': 1,
              'training_id': 1,
              'training_exercises': [],
              'sets': 4,
              'set_rest': 60,
              'multiset_rest': 120,
              'special_instructions': 'Do it slowly',
              'objectives': 'Increase strength',
            }
          ],
          'training_exercises': []
        };
        final multisetUpdatedNoExercise = createMultiset(
          id: 1,
          trainingId: 1,
        );
        final trainingUpdate2 = createTraining(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdatedNoExercise],
        );
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : update the training
        await dataSource.updateTraining(trainingUpdate2);

        // Assert : compare the updated training to what's exepected
        final updatedTraining = await dataSource.getTraining(1);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdate2Json));

        await _verifyDatabase(
            db: db,
            multisetsListMatcher: [multisetUpdated.toJson()],
            trainingExercisesListMatcher: []);
      },
    );

    test(
      'UPDATE 3 : should update the training and its training exercises and create new training exercises when they have no id',
      () async {
        // Arrange
        final multisetTrainingExerciseUpdate3 = createTrainingExercise(
            trainingId: 1,
            multisetId: 1,
            exerciseId: 1,
            specialInstructions: 'ADDED COZ NO ID');

        final multisetUpdate3 = createMultiset(
          id: 1,
          trainingId: 1,
          trainingExercises: [
            multisetTrainingExerciseUpdated,
            multisetTrainingExerciseUpdate3
          ],
        );

        final trainingExerciseUpdate3 = createTrainingExercise(
            trainingId: 1, specialInstructions: 'ADDED COZ NO ID');

        final trainingUpdate3 = createTraining(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdate3],
          trainingExercises: [trainingExerciseUpdated, trainingExerciseUpdate3],
        );

        final trainingUpdate3Json = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [
            {
              'id': 1,
              'training_id': 1,
              'training_exercises': [
                createTrainingExercise(
                        id: 1,
                        trainingId: 1,
                        multisetId: 1,
                        specialInstructions: 'EDITED')
                    .toJson(),
                createTrainingExercise(
                        id: 3,
                        trainingId: 1,
                        multisetId: 1,
                        specialInstructions: 'ADDED COZ NO ID')
                    .toJson(),
              ],
              'sets': 4,
              'set_rest': 60,
              'multiset_rest': 120,
              'special_instructions': 'Do it slowly',
              'objectives': 'Increase strength',
            }
          ],
          'training_exercises': [
            createTrainingExercise(
                    id: 2, trainingId: 1, specialInstructions: 'EDITED')
                .toJson(),
            createTrainingExercise(
                    id: 4,
                    trainingId: 1,
                    specialInstructions: 'ADDED COZ NO ID')
                .toJson(),
          ]
        };

        final trainingExercisesListUpdate3 = [
          createTrainingExercise(
                  id: 1,
                  trainingId: 1,
                  multisetId: 1,
                  specialInstructions: 'EDITED')
              .toJson(),
          createTrainingExercise(
                  id: 2, trainingId: 1, specialInstructions: 'EDITED')
              .toJson(),
          createTrainingExercise(
                  id: 3,
                  trainingId: 1,
                  multisetId: 1,
                  specialInstructions: 'ADDED COZ NO ID')
              .toJson(),
          createTrainingExercise(
                  id: 4, trainingId: 1, specialInstructions: 'ADDED COZ NO ID')
              .toJson(),
        ];
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : update the training
        await dataSource.updateTraining(trainingUpdate3);

        // Assert : compare the updated training to what's exepected
        final updatedTraining = await dataSource.getTraining(1);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdate3Json));

        await _verifyDatabase(
            db: db,
            multisetsListMatcher: [multisetUpdated.toJson()],
            trainingExercisesListMatcher: trainingExercisesListUpdate3);
      },
    );

    test(
      'UPDATE 4 : should update the training and delete its multisets',
      () async {
        // Arrange
        final trainingUpdate4 = createTraining(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          trainingExercises: [trainingExerciseUpdated],
        );

        final trainingUpdate4Json = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [],
          'training_exercises': [
            createTrainingExercise(
                    id: 2, trainingId: 1, specialInstructions: 'EDITED')
                .toJson()
          ]
        };
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : update the training
        await dataSource.updateTraining(trainingUpdate4);

        // Assert : compare the updated training to what's exepected
        final updatedTraining = await dataSource.getTraining(1);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdate4Json));

        await _verifyDatabase(
            db: db,
            multisetsListMatcher: [],
            trainingExercisesListMatcher: [trainingExerciseUpdated.toJson()]);
      },
    );

    test(
      'UPDATE 5 : should update the training and its multisets and create multisets when they have no id',
      () async {
        // Arrange
        final multisetUpdate5 = createMultiset(
          id: 1,
          trainingId: 1,
          trainingExercises: [multisetTrainingExerciseUpdated],
        );

        final multisetTrainingExerciseUpdate5NoId = createTrainingExercise(
            trainingId: 1, specialInstructions: 'CREATED');

        final multisetUpdate5LocalNoId = createMultiset(
          trainingId: 1,
          specialInstructions: 'ADDED COZ NO ID',
          trainingExercises: [multisetTrainingExerciseUpdate5NoId],
        );
        final trainingUpdateLocal = createTraining(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdate5, multisetUpdate5LocalNoId],
          trainingExercises: [trainingExerciseUpdated],
        );

        final trainingUpdate5Json = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [
            {
              'id': 1,
              'training_id': 1,
              'training_exercises': [
                createTrainingExercise(
                        id: 1,
                        trainingId: 1,
                        multisetId: 1,
                        specialInstructions: 'EDITED')
                    .toJson(),
              ],
              'sets': 4,
              'set_rest': 60,
              'multiset_rest': 120,
              'special_instructions': 'Do it slowly',
              'objectives': 'Increase strength',
            },
            {
              'id': 2,
              'training_id': 1,
              'training_exercises': [
                createTrainingExercise(
                        id: 3,
                        trainingId: 1,
                        multisetId: 2,
                        specialInstructions: 'CREATED')
                    .toJson(),
              ],
              'sets': 4,
              'set_rest': 60,
              'multiset_rest': 120,
              'special_instructions': 'ADDED COZ NO ID',
              'objectives': 'Increase strength',
            }
          ],
          'training_exercises': [
            createTrainingExercise(
                    id: 2, trainingId: 1, specialInstructions: 'EDITED')
                .toJson()
          ]
        };

        final multisetsListMatcherUpdate5 = [
          createMultiset(id: 1, trainingId: 1).toJson(),
          createMultiset(
                  id: 2, trainingId: 1, specialInstructions: 'ADDED COZ NO ID')
              .toJson(),
        ];

        final trainingExercisesListMatcherUpdate5 = [
          createTrainingExercise(
                  id: 1,
                  trainingId: 1,
                  multisetId: 1,
                  specialInstructions: 'EDITED')
              .toJson(),
          createTrainingExercise(
                  id: 2, trainingId: 1, specialInstructions: 'EDITED')
              .toJson(),
          createTrainingExercise(
                  id: 3,
                  trainingId: 1,
                  multisetId: 2,
                  specialInstructions: 'CREATED')
              .toJson()
        ];
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : update the training
        await dataSource.updateTraining(trainingUpdateLocal);

        // Assert : compare the updated training to what's exepected
        final updatedTraining = await dataSource.getTraining(1);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdate5Json));

        await _verifyDatabase(
            db: db,
            multisetsListMatcher: multisetsListMatcherUpdate5,
            trainingExercisesListMatcher: trainingExercisesListMatcherUpdate5);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );
  });

  group('delete training', () {
    test(
      'should delete the specified training and all its multisets/training exercises associated',
      () async {
        // Arrange
        await _initTraining(exerciseLocalDataSource, dataSource);

        // Act : delete the training
        await dataSource.deleteTraining(1);

        // Assert : check that the training and the multisets/training exercises associated with it are deleted
        final trainingsList = await dataSource.fetchTrainings();
        expect(trainingsList, []);

        await _verifyDatabase(
            db: db, multisetsListMatcher: [], trainingExercisesListMatcher: []);
      },
    );
  });
}

Future<void> _initTraining(ExerciseLocalDataSource exerciseLocalDataSource,
    TrainingLocalDataSource dataSource) async {
  final exerciseResult = await exerciseLocalDataSource.createExercise(exercise);
  expect(exerciseResult.name, exercise.name);
  expect(exerciseResult.id, isNotNull);

  final trainingResult = await dataSource.createTraining(trainingBase);
  expect(trainingResult.name, trainingBase.name);
  expect(trainingResult.id, isNotNull);

  final createdTraining = await dataSource.getTraining(1);
  expect(createdTraining, TrainingModel.fromJson(trainingBaseJson));
}

Future<void> _verifyDatabase(
    {required Database db,
    required multisetsListMatcher,
    required trainingExercisesListMatcher}) async {
  final multisetsList = await db.query('multisets');
  expect(multisetsList, multisetsListMatcher);

  final trainingExercisesList = await db.query('training_exercises');
  expect(trainingExercisesList, trainingExercisesListMatcher);

  final exercisesList = await db.query('exercises');
  expect(exercisesList, [exerciseJson]);
}

Future<void> _createTables(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
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

TrainingExerciseModel createTrainingExercise({
  int? id,
  int? trainingId,
  int? multisetId,
  int exerciseId = 1,
  String name = "Downward Dog",
  String description = "Awesome description",
  String imagePath = "pathToImage",
  TrainingExerciseType type = TrainingExerciseType.yoga,
  String specialInstructions = "",
  String objectives = "",
  int targetDistance = 5000,
  int targetDuration = 1800,
  int targetRythm = 80,
  int intervals = 5,
  int intervalDistance = 1000,
  int intervalDuration = 300,
  int intervalRest = 60,
  int sets = 3,
  int reps = 15,
  int duration = 600,
  int setRest = 120,
  int exerciseRest = 90,
  bool manualStart = true,
}) {
  return TrainingExerciseModel(
    id: id,
    trainingId: trainingId,
    multisetId: multisetId,
    exerciseId: exerciseId,
    trainingExerciseType: type,
    sets: sets,
    reps: reps,
    duration: duration,
    setRest: setRest,
    exerciseRest: exerciseRest,
    manualStart: manualStart,
    targetDistance: targetDistance,
    targetDuration: targetDuration,
    targetRythm: targetRythm,
    intervals: intervals,
    intervalDistance: intervalDistance,
    intervalDuration: intervalDuration,
    intervalRest: intervalRest,
    specialInstructions: specialInstructions,
    objectives: objectives,
  );
}

MultisetModel createMultiset({
  int? id,
  int? trainingId,
  String specialInstructions = "Do it slowly",
  String objectives = "Increase strength",
  List<TrainingExerciseModel> trainingExercises = const [],
}) {
  return MultisetModel(
    id: id,
    trainingId: trainingId,
    sets: 4,
    setRest: 60,
    multisetRest: 120,
    specialInstructions: specialInstructions,
    objectives: objectives,
    trainingExercises: trainingExercises,
  );
}

TrainingModel createTraining({
  int? id,
  String name = 'Full Body Workout',
  TrainingType type = TrainingType.yoga,
  bool isSelected = true,
  List<TrainingExercise> trainingExercises = const [],
  List<Multiset> multisets = const [],
}) {
  return TrainingModel(
      id: id,
      name: name,
      type: type,
      isSelected: isSelected,
      trainingExercises: trainingExercises,
      multisets: multisets);
}
