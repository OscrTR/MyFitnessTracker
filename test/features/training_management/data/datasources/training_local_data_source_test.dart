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

  const exerciseJson = {
    'id': 1,
    'name': 'Downward Dog',
    'description': 'Awesome description',
    'image_path': 'pathToImage'
  };

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

  const fetchTrainingsMatcher = TrainingModel(
      id: 1,
      name: 'Full Body Workout',
      type: TrainingType.yoga,
      isSelected: true,
      multisets: [],
      trainingExercises: []);

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
          {
            "id": 1,
            "training_id": 1,
            "multiset_id": 1,
            "exercise_id": 1,
            "name": "Downward Dog",
            "description": "Awesome description",
            "imagePath": "pathToImage",
            "training_exercise_type": 1,
            "special_instructions": "EDITED",
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
        "special_instructions": "EDITED",
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
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Assert : get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));
      },
    );
  });

  group('fetch trainings', () {
    test(
      'should retrieve all the trainings with their minimal info (no multisets/training exercises)',
      () async {
        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create a training to fetch later
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Assert : fetch all trainings and compare the result to what's expected
        final result = await dataSource.fetchTrainings();
        expect(result, [fetchTrainingsMatcher]);
      },
    );
  });

  group('update training', () {
    const trainingExerciseUpdated = TrainingExerciseModel(
      id: 2,
      trainingId: 1,
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
      specialInstructions: 'EDITED',
      objectives: '',
    );

    const multisetTrainingExerciseUpdated = TrainingExerciseModel(
      id: 1,
      trainingId: 1,
      multisetId: 1,
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
      specialInstructions: 'EDITED',
      objectives: '',
    );

    const multisetUpdated = MultisetModel(
      id: 1,
      trainingId: 1,
      sets: 4,
      setRest: 60,
      multisetRest: 120,
      specialInstructions: 'Do it slowly',
      objectives: 'Increase strength',
      trainingExercises: [multisetTrainingExerciseUpdated],
    );

    const multisetUpdatedNoExercise = MultisetModel(
      id: 1,
      trainingId: 1,
      sets: 4,
      setRest: 60,
      multisetRest: 120,
      specialInstructions: 'Do it slowly',
      objectives: 'Increase strength',
      trainingExercises: [],
    );

    const trainingUpdate = TrainingModel(
      id: 1,
      name: 'EDITED Full Body Workout',
      type: TrainingType.run,
      isSelected: false,
      multisets: [multisetUpdated],
      trainingExercises: [trainingExerciseUpdated],
    );

    test(
      'should update the training, its multisets and its training exercises',
      () async {
        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create the training
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : update the training
        await dataSource.updateTraining(trainingUpdate);

        // Assert : compare the updated training to what's exepected
        final updatedTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(updatedTraining, TrainingModel.fromJson(trainingUpdatedJson));

        // Verify that the exercises, training exercises and multisets are also correct
        final multisetsList = await db.query('multisets');
        expect(multisetsList, [multisetUpdated.toJson()]);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, [
          multisetTrainingExerciseUpdated.toJson(),
          trainingExerciseUpdated.toJson()
        ]);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );

    test(
      'should update the training and delete the training exercises',
      () async {
        const trainingUpdateLocal = TrainingModel(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdatedNoExercise],
          trainingExercises: [],
        );

        final trainingUpdatedJsonLocal = {
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

        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create the training
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : update the training
        await dataSource.updateTraining(trainingUpdateLocal);

        // Assert : compare the updated training to what's exepected
        final updatedTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(
            updatedTraining, TrainingModel.fromJson(trainingUpdatedJsonLocal));

        // Verify that the exercises, training exercises and multisets are also correct
        final multisetsList = await db.query('multisets');
        expect(multisetsList, [multisetUpdated.toJson()]);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, []);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );

    test(
      'should update the training and its training exercises and create new training exercises when they have no id',
      () async {
        const multisetTrainingExerciseUpdatedLocal = TrainingExerciseModel(
          id: null,
          trainingId: 1,
          multisetId: 1,
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
          specialInstructions: 'ADDED COZ NO ID',
          objectives: '',
        );

        const multisetUpdatedLocal = MultisetModel(
          id: 1,
          trainingId: 1,
          sets: 4,
          setRest: 60,
          multisetRest: 120,
          specialInstructions: 'Do it slowly',
          objectives: 'Increase strength',
          trainingExercises: [
            multisetTrainingExerciseUpdated,
            multisetTrainingExerciseUpdatedLocal
          ],
        );
        const trainingExerciseUpdatedLocal = TrainingExerciseModel(
          id: null,
          trainingId: 1,
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
          specialInstructions: 'ADDED COZ NO ID',
          objectives: '',
        );
        const trainingUpdateLocal = TrainingModel(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdatedLocal],
          trainingExercises: [
            trainingExerciseUpdated,
            trainingExerciseUpdatedLocal
          ],
        );

        final trainingUpdatedJsonLocal = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
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
                  "special_instructions": "EDITED",
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
                },
                {
                  "id": 3,
                  "training_id": 1,
                  "multiset_id": 1,
                  "exercise_id": 1,
                  "name": "Downward Dog",
                  "description": "Awesome description",
                  "imagePath": "pathToImage",
                  "training_exercise_type": 1,
                  "special_instructions": "ADDED COZ NO ID",
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
              "special_instructions": "EDITED",
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
            },
            {
              "id": 4,
              "training_id": 1,
              "multiset_id": null,
              "exercise_id": 1,
              "name": "Downward Dog",
              "description": "Awesome description",
              "imagePath": "pathToImage",
              "training_exercise_type": 1,
              "special_instructions": "ADDED COZ NO ID",
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

        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create the training
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : update the training
        await dataSource.updateTraining(trainingUpdateLocal);

        // Assert : compare the updated training to what's exepected
        final updatedTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(
            updatedTraining, TrainingModel.fromJson(trainingUpdatedJsonLocal));

        // Verify that the exercises, training exercises and multisets are also correct
        final multisetsList = await db.query('multisets');
        expect(multisetsList, [multisetUpdated.toJson()]);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, [
          {
            "id": 1,
            "training_id": 1,
            "multiset_id": 1,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "EDITED",
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
          },
          {
            "id": 2,
            "training_id": 1,
            "multiset_id": null,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "EDITED",
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
          },
          {
            "id": 3,
            "training_id": 1,
            "multiset_id": 1,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "ADDED COZ NO ID",
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
          },
          {
            "id": 4,
            "training_id": 1,
            "multiset_id": null,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "ADDED COZ NO ID",
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
        ]);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );

    test(
      'should update the training and delete its multisets',
      () async {
        const trainingUpdateLocal = TrainingModel(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [],
          trainingExercises: [trainingExerciseUpdated],
        );

        final trainingUpdatedJsonLocal = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
          'multisets': [],
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
              "special_instructions": "EDITED",
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
        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create the training
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : update the training
        await dataSource.updateTraining(trainingUpdateLocal);

        // Assert : compare the updated training to what's exepected
        final updatedTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(
            updatedTraining, TrainingModel.fromJson(trainingUpdatedJsonLocal));

        // Verify that the exercises, training exercises and multisets are also correct
        final multisetsList = await db.query('multisets');
        expect(multisetsList, []);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, [trainingExerciseUpdated.toJson()]);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );

    test(
      'should update the training and its multisets and create multisets when they have no id',
      () async {
        const multisetUpdatedLocal = MultisetModel(
          id: 1,
          trainingId: 1,
          sets: 4,
          setRest: 60,
          multisetRest: 120,
          specialInstructions: 'Do it slowly',
          objectives: 'Increase strength',
          trainingExercises: [multisetTrainingExerciseUpdated],
        );

        const multisetTrainingExerciseUpdatedNoId = TrainingExerciseModel(
          id: null,
          trainingId: 1,
          multisetId: null, // Multiset id inconnu puisque pas encore créé
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
          specialInstructions: 'CREATED',
          objectives: '',
        );

        const multisetUpdatedLocalNoId = MultisetModel(
          id: null,
          trainingId: 1,
          sets: 4,
          setRest: 60,
          multisetRest: 120,
          specialInstructions: 'ADDED COZ NO ID',
          objectives: 'Increase strength',
          trainingExercises: [multisetTrainingExerciseUpdatedNoId],
        );

        const trainingUpdateLocal = TrainingModel(
          id: 1,
          name: 'EDITED Full Body Workout',
          type: TrainingType.run,
          isSelected: false,
          multisets: [multisetUpdatedLocal, multisetUpdatedLocalNoId],
          trainingExercises: [trainingExerciseUpdated], // exo avec id = 2
        );

        final trainingUpdatedJsonLocal = {
          'id': 1,
          'name': 'EDITED Full Body Workout',
          'type': 0,
          'is_selected': 0,
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
                  "special_instructions": "EDITED",
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
            },
            {
              'id': 2,
              'training_id': 1,
              'training_exercises': [
                {
                  "id": 3,
                  "training_id": 1,
                  "multiset_id": 2,
                  "exercise_id": 1,
                  "name": "Downward Dog",
                  "description": "Awesome description",
                  "imagePath": "pathToImage",
                  "training_exercise_type": 1,
                  "special_instructions": "CREATED",
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
              'special_instructions': 'ADDED COZ NO ID',
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
              "special_instructions": "EDITED",
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

        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create the training
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Get the training and compare it with the actual training
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : update the training
        await dataSource.updateTraining(trainingUpdateLocal);

        // Assert : compare the updated training to what's exepected
        final updatedTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(
            updatedTraining, TrainingModel.fromJson(trainingUpdatedJsonLocal));

        // Verify that the exercises, training exercises and multisets are also correct
        final multisetsList = await db.query('multisets');
        expect(multisetsList, [
          {
            'id': 1,
            'training_id': 1,
            'sets': 4,
            'set_rest': 60,
            'multiset_rest': 120,
            'special_instructions': 'Do it slowly',
            'objectives': 'Increase strength'
          },
          {
            'id': 2,
            'training_id': 1,
            'sets': 4,
            'set_rest': 60,
            'multiset_rest': 120,
            'special_instructions': 'ADDED COZ NO ID',
            'objectives': 'Increase strength'
          }
        ]);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, [
          {
            "id": 1,
            "training_id": 1,
            "multiset_id": 1,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "EDITED",
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
          },
          {
            "id": 2,
            "training_id": 1,
            "multiset_id": null,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "EDITED",
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
          },
          {
            "id": 3,
            "training_id": 1,
            "multiset_id": 2,
            "exercise_id": 1,
            "training_exercise_type": 1,
            "special_instructions": "CREATED",
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
        ]);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );
  });

  group('delete training', () {
    test(
      'should delete the specified training and all its multisets/training exercises associated',
      () async {
        // Arrange : create a valid exercise to use for the training exercises
        final exerciseResult =
            await exerciseLocalDataSource.createExercise(exercise);
        expect(exerciseResult.name, exercise.name);
        expect(exerciseResult.id, isNotNull);

        // Create a training to delete later
        final trainingResult = await dataSource.createTraining(training);
        expect(trainingResult.name, training.name);
        expect(trainingResult.id, isNotNull);

        // Verify the training is actually created
        final createdTraining =
            await dataSource.getTraining(trainingResult.id!);
        expect(createdTraining, TrainingModel.fromJson(trainingJson));

        // Act : delete the training
        await dataSource.deleteTraining(trainingResult.id!);

        // Assert : check that the training and the multisets/training exercises associated with it are deleted
        final trainingsList = await dataSource.fetchTrainings();
        expect(trainingsList, []);

        final multisetsList = await db.query('multisets');
        expect(multisetsList, []);

        final trainingExercisesList = await db.query('training_exercises');
        expect(trainingExercisesList, []);

        final exercisesList = await db.query('exercises');
        expect(exercisesList, [exerciseJson]);
      },
    );
  });
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
