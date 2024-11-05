import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/training_exercise_local_data_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  unitTesting();
  integrationTesting();
}

void unitTesting() {
  late SQLiteTrainingExerciseLocalDataSource dataSourceSQLite;
  late MockDatabase mockDatabase;

  setUp(() async {
    mockDatabase = MockDatabase();
    dataSourceSQLite =
        SQLiteTrainingExerciseLocalDataSource(database: mockDatabase);
  });

  const trainingId = 1;

  const trainingExercise = TrainingExerciseModel(
    id: 1,
    trainingId: 1,
    multisetId: 2,
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

  final trainingExerciseJson = {
    'id': 1,
    'training_id': 1,
    'multiset_id': 2,
    'exercise_id': 3,
    'training_exercise_type': 1,
    'sets': 3,
    'reps': 15,
    'duration': 600,
    'set_rest': 120,
    'exercise_rest': 90,
    'manual_start': true,
    'target_distance': 5000,
    'target_duration': 1800,
    'target_rythm': 80,
    'intervals': 5,
    'interval_distance': 1000,
    'interval_duration': 300,
    'interval_rest': 60,
  };

  group('createTrainingExercise', () {
    test('should insert a training exercise into the database and return it',
        () async {
      // Arrange: Mock the insert response
      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);
      // Act
      final result =
          await dataSourceSQLite.createTrainingExercise(trainingExercise);

      // Assert
      // Verify that the insert was called on the mockDatabase with the expected values
      verify(() => mockDatabase.insert(
            any(),
            {
              'id': 1,
              'training_id': 1,
              'multiset_id': 2,
              'exercise_id': 3,
              'training_exercise_type': 1,
              'sets': 3,
              'reps': 15,
              'duration': 600,
              'set_rest': 120,
              'exercise_rest': 90,
              'manual_start': true,
              'target_distance': 5000,
              'target_duration': 1800,
              'target_rythm': 80,
              'intervals': 5,
              'interval_distance': 1000,
              'interval_duration': 300,
              'interval_rest': 60,
              'special_instructions': '',
              'objectives': '',
            },
          )).called(1);

      // Verify the returned trainingExercise
      expect(result.id, 1);
      expect(result.trainingExerciseType, TrainingExerciseType.yoga);
      expect(result.sets, 3);
      expect(result.objectives, '');
    });

    test('should throw LocalDatabaseException on error', () async {
      // Arrange
      when(() => mockDatabase.insert(any(), any()))
          .thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(
        () => dataSourceSQLite.createTrainingExercise(trainingExercise),
        throwsA(isA<LocalDatabaseException>()),
      );
    });
  });

  group('fetchTrainingExercises', () {
    test('should return a list of TrainingExerciseModel from the database',
        () async {
      // Arrange
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => [trainingExerciseJson]);

      // Act
      final result = await dataSourceSQLite.fetchTrainingExercises(trainingId);

      // Assert
      expect(result, isA<List<TrainingExerciseModel>>());
      expect(result.length, 1);
      expect(result[0].id, trainingExerciseJson['id']);
    });

    test('should throw LocalDatabaseException on error', () async {
      // Arrange
      when(() => mockDatabase.query(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      // Act & Assert
      expect(
        () => dataSourceSQLite.fetchTrainingExercises(trainingId),
        throwsA(isA<LocalDatabaseException>()),
      );
    });
  });

  group('updateTrainingExercise', () {
    test('should update a training exercise in the database and return it',
        () async {
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      final result =
          await dataSourceSQLite.updateTrainingExercise(trainingExercise);

      verify(() => mockDatabase.update(
            'training_exercises',
            trainingExercise.toJson(),
            where: 'id = ?',
            whereArgs: [trainingExercise.id],
          )).called(1);

      expect(result, trainingExercise);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSourceSQLite.updateTrainingExercise(trainingExercise),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('deleteTrainingExercise', () {
    test('should delete a training exercise from the database', () async {
      when(() => mockDatabase.delete(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => 1);

      await dataSourceSQLite.deleteTrainingExercise(trainingExercise.id!);

      verify(() => mockDatabase.delete(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).called(1);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(
          () => dataSourceSQLite.deleteTrainingExercise(trainingExercise.id!),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}

void integrationTesting() {}
