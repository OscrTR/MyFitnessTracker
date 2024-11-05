import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/multiset_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  late SQLiteMultisetLocalDataSource dataSource;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    dataSource = SQLiteMultisetLocalDataSource(database: mockDatabase);
  });

  const multisetId = 1;
  const trainingId = 1;

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

  final multisetJson = {
    'id': multisetId,
    'training_id': trainingId,
    'sets': 4,
    'set_rest': 60,
    'multiset_rest': 120,
    'special_instructions': 'Do it slowly',
    'objectives': 'Increase strength',
  };

  final multisetJsonResponse = {
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
  };

  final trainingExerciseJson = trainingExercise.toJson();

  group('createMultiset', () {
    test('should insert a multiset and associated training exercises',
        () async {
      // Arrange: Mock the database insert responses
      when(() => mockDatabase.insert('multisets', any()))
          .thenAnswer((_) async => multisetId);
      when(() => mockDatabase.insert('training_exercises', any()))
          .thenAnswer((_) async => trainingExercise.id!);

      // Act
      final result = await dataSource.createMultiset(multiset);

      // Assert: Verify that the multiset and associated exercises were inserted
      verify(() => mockDatabase.insert('multisets', multisetJson)).called(1);
      verify(() =>
              mockDatabase.insert('training_exercises', trainingExerciseJson))
          .called(1);
      expect(result.id, multisetId);
    });

    test('should throw LocalDatabaseException on error', () async {
      // Arrange
      when(() => mockDatabase.insert(any(), any())).thenThrow(Exception());

      // Act & Assert
      expect(() => dataSource.createMultiset(multiset),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('fetchMultisets', () {
    test('should return a list of MultisetModel from the database', () async {
      // Arrange
      when(() => mockDatabase.query('multisets',
              where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [multisetJsonResponse]);

      // Act
      final result = await dataSource.fetchMultisets(trainingId);

      // Assert
      expect(result, isA<List<MultisetModel>>());
      expect(result.length, 1);
      expect(result[0].id, multisetJson['id']);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.query(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSource.fetchMultisets(trainingId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('updateMultiset', () {
    test('should update a multiset and its associated training exercises',
        () async {
      // Arrange: Mock the database update responses
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

      // Act
      final result = await dataSource.updateMultiset(multiset);

      // Assert: Verify the update and insertion calls
      verify(() => mockDatabase.update('multisets', multisetJson,
          where: 'id = ?', whereArgs: [multiset.id])).called(1);
      verify(() => mockDatabase.update(
          'training_exercises', trainingExerciseJson,
          where: 'id = ?', whereArgs: [trainingExercise.id])).called(1);
      expect(result.id, multisetId);
    });

    test('should delete orphaned training exercises and update existing ones',
        () async {
      // Arrange: Mock database responses
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      await dataSource.updateMultiset(multiset);

      verify(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).called(1);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSource.updateMultiset(multiset),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('deleteMultiset', () {
    test('should delete a multiset from the database', () async {
      when(() => mockDatabase.delete('multisets',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      await dataSource.deleteMultiset(multisetId);

      verify(() => mockDatabase.delete('multisets',
          where: 'id = ?', whereArgs: [multisetId])).called(1);
    });

    test('should throw LocalDatabaseException on error', () async {
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      expect(() => dataSource.deleteMultiset(multisetId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}
