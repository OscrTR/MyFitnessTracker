import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/training_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  late SQLiteTrainingLocalDataSource dataSource;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    dataSource = SQLiteTrainingLocalDataSource(database: mockDatabase);
  });

  const trainingId = 1;
  const multisetId = 2;

  const trainingExercise = TrainingExerciseModel(
    id: 1,
    trainingId: trainingId,
    multisetId: multisetId,
    exerciseId: 3,
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

  const trainingExerciseNoId = TrainingExerciseModel(
    id: null,
    trainingId: trainingId,
    multisetId: multisetId,
    exerciseId: 3,
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
    id: multisetId,
    trainingId: trainingId,
    sets: 4,
    setRest: 60,
    multisetRest: 120,
    specialInstructions: 'Do it slowly',
    objectives: 'Increase strength',
    trainingExercises: [trainingExercise],
  );

  const multisetNoId = MultisetModel(
    id: null,
    trainingId: trainingId,
    sets: 4,
    setRest: 60,
    multisetRest: 120,
    specialInstructions: 'Do it slowly',
    objectives: 'Increase strength',
    trainingExercises: [trainingExercise],
  );

  const multisetTrainingExerciseNoId = MultisetModel(
    id: multisetId,
    trainingId: trainingId,
    sets: 4,
    setRest: 60,
    multisetRest: 120,
    specialInstructions: 'Do it slowly',
    objectives: 'Increase strength',
    trainingExercises: [trainingExerciseNoId],
  );

  const training = TrainingModel(
    id: trainingId,
    name: 'Full Body Workout',
    type: TrainingType.yoga,
    isSelected: true,
    multisets: [multiset],
    trainingExercises: [trainingExercise],
  );

  const trainingMultisetNoId = TrainingModel(
    id: trainingId,
    name: 'Full Body Workout',
    type: TrainingType.yoga,
    isSelected: true,
    multisets: [multisetNoId],
    trainingExercises: [trainingExercise],
  );

  const trainingTrainingExerciseNoId = TrainingModel(
    id: trainingId,
    name: 'Full Body Workout',
    type: TrainingType.yoga,
    isSelected: true,
    multisets: [multisetTrainingExerciseNoId],
    trainingExercises: [trainingExerciseNoId],
  );

  final trainingJson = {
    'id': trainingId,
    'name': 'Full Body Workout',
    'type': 1,
    'is_selected': true,
    'multisets': [
      {
        'id': multisetId,
        'training_id': trainingId,
        'training_exercises': [
          {
            "id": 1,
            "training_id": trainingId,
            "multiset_id": multisetId,
            "exercise_id": 3,
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
            "manual_start": true
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
        "id": 1,
        "training_id": trainingId,
        "multiset_id": multisetId,
        "exercise_id": 3,
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
        "manual_start": true
      }
    ]
  };

  group('createTraining', () {
    test(
        'should insert a training, its multisets, and associated training exercises',
        () async {
      // Arrange
      when(() => mockDatabase.insert('trainings', any()))
          .thenAnswer((_) async => trainingId);
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => multisetId);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);

      // Act
      final result = await dataSource.createTraining(training);

      // Assert
      verify(() => mockDatabase.insert('trainings', training.toJson()))
          .called(1);
      verify(() => mockDatabase.insert('multisets', multiset.toJson()))
          .called(1);
      verify(() => mockDatabase.insert(
              'training_exercises', trainingExercise.toJson()))
          .called(2); // once for each exercise
      expect(result.id, trainingId);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.insert(any(), any())).thenThrow(Exception());

      expect(() => dataSource.createTraining(training),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('fetchTrainings', () {
    test('should return a list of TrainingModel from the database', () async {
      // Arrange
      when(() => mockDatabase.query('trainings'))
          .thenAnswer((_) async => [trainingJson]);

      // Act
      final result = await dataSource.fetchTrainings();

      // Assert
      expect(result, isA<List<TrainingModel>>());
      expect(result.length, 1);
      expect(result[0].id, trainingJson['id']);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.query(any())).thenThrow(Exception());

      expect(() => dataSource.fetchTrainings(),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('getTraining', () {
    test('should return a TrainingModel when a training is found', () async {
      // Arrange
      when(() => mockDatabase.query('trainings',
          where: 'id = ?',
          whereArgs: [trainingId])).thenAnswer((_) async => [trainingJson]);

      // Act
      final result = await dataSource.getTraining(trainingId);

      // Assert
      expect(result.id, trainingId);
      expect(result.name, training.name);
    });

    test('should throw LocalDatabaseException when no training is found',
        () async {
      when(() => mockDatabase.query('trainings',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => []);

      expect(() => dataSource.getTraining(trainingId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('updateTraining', () {
    test(
        'should update a training, its multisets, and associated training exercises',
        () async {
      // Arrange
      when(() => mockDatabase.update('trainings', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('multisets', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('training_exercises', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);
      when(() => mockDatabase.delete('training_exercises',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      // Act
      final result = await dataSource.updateTraining(training);

      // Assert
      verify(() => mockDatabase.update('trainings', training.toJson(),
          where: 'id = ?', whereArgs: [training.id])).called(1);
      verify(() => mockDatabase.update('multisets', multiset.toJson(),
          where: 'id = ?', whereArgs: [multiset.id])).called(1);
      verify(() => mockDatabase.update(
          'training_exercises', trainingExercise.toJson(),
          where: 'id = ?', whereArgs: [trainingExercise.id])).called(2);
      expect(result.id, training.id);
    });

    test('should update existing multiset and insert a new one if not found',
        () async {
      // Arrange
      when(() => mockDatabase.update('trainings', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('multisets', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 0);
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => multisetId);
      when(() => mockDatabase.update('training_exercises', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);
      when(() => mockDatabase.delete('training_exercises',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      // Act
      final result = await dataSource.updateTraining(training);

      // Assert
      verify(() => mockDatabase.update('trainings', training.toJson(),
          where: 'id = ?', whereArgs: [training.id])).called(1);
      verify(() => mockDatabase.update('multisets', multiset.toJson(),
          where: 'id = ?', whereArgs: [multiset.id])).called(1);
      verify(() => mockDatabase.update(
          'training_exercises', trainingExercise.toJson(),
          where: 'id = ?', whereArgs: [trainingExercise.id])).called(2);
      expect(result.id, training.id);
    });

    test('should insert new multiset if they have no id', () async {
      // Arrange
      when(() => mockDatabase.update('trainings', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('multisets', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => 2);
      when(() => mockDatabase.update('training_exercises', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);
      when(() => mockDatabase.delete('training_exercises',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      // Act
      final result = await dataSource.updateTraining(trainingMultisetNoId);

      // Assert
      verify(() => mockDatabase.update('trainings', training.toJson(),
          where: 'id = ?', whereArgs: [training.id])).called(1);
      verify(() => mockDatabase.insert('multisets', multisetNoId.toJson()))
          .called(1);
      verify(() => mockDatabase.update(
          'training_exercises', trainingExercise.toJson(),
          where: 'id = ?', whereArgs: [trainingExercise.id])).called(2);
      expect(result.id, training.id);
    });

    test(
        'should update existing trainingExercise and insert a new one if not found',
        () async {
      // Arrange
      when(() => mockDatabase.update('trainings', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('multisets', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => multisetId);
      when(() => mockDatabase.update('training_exercises', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 0);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);
      when(() => mockDatabase.delete('training_exercises',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      // Act
      final result = await dataSource.updateTraining(training);

      // Assert
      verify(() => mockDatabase.update('trainings', training.toJson(),
          where: 'id = ?', whereArgs: [training.id])).called(1);
      verify(() => mockDatabase.update('multisets', multiset.toJson(),
          where: 'id = ?', whereArgs: [multiset.id])).called(1);
      verify(() => mockDatabase.update(
          'training_exercises', trainingExercise.toJson(),
          where: 'id = ?', whereArgs: [trainingExercise.id])).called(2);
      expect(result.id, training.id);
    });

    test('should insert new trainingExercise if they have no id', () async {
      // Arrange
      when(() => mockDatabase.update('trainings', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.update('multisets', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => 2);
      when(() => mockDatabase.update('training_exercises', any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);
      when(() => mockDatabase.delete('training_exercises',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      // Act
      final result =
          await dataSource.updateTraining(trainingTrainingExerciseNoId);

      // Assert
      verify(() => mockDatabase.update('trainings', training.toJson(),
          where: 'id = ?', whereArgs: [training.id])).called(1);
      verify(() => mockDatabase.insert(
          'training_exercises', trainingExerciseNoId.toJson())).called(2);
      expect(result.id, training.id);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSource.updateTraining(training),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('deleteTraining', () {
    test('should delete a training from the database', () async {
      when(() => mockDatabase.delete('trainings',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      await dataSource.deleteTraining(trainingId);

      verify(() => mockDatabase.delete('trainings',
          where: 'id = ?', whereArgs: [trainingId])).called(1);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSource.deleteTraining(trainingId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}
