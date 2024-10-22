import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  late SQLiteExerciseLocalDataSource dataSourceSQLite;
  late MockDatabase mockDatabase;

  setUp(() async {
    mockDatabase = MockDatabase();
    dataSourceSQLite = SQLiteExerciseLocalDataSource(mockDatabase);
  });

  group('createExercise', () {
    const tExercise = Exercise(
      name: 'Deadlift',
      imageName: 'deadlift.png',
      description: 'A full body exercise',
    );

    test(
      'should insert a new Exercise into SQLite Database and return the created ExerciseModel',
      () async {
        // Arrange: Mock the insert response
        when(() => mockDatabase.insert(any(), any()))
            .thenAnswer((_) async => 1);

        // Act
        final result = await dataSourceSQLite.createExercise(tExercise);

        // Assert
        // Verify the returned exercise
        expect(result.name, 'Deadlift');
        expect(result.description, 'A full body exercise');
        expect(result.imageName, 'deadlift.png');
        expect(result.id, isNotNull); // Ensure it has an auto-generated id
      },
    );

    test('should throw a DatabaseException when insert fails', () async {
      // Arrange: Mock the insert to throw an exception
      when(() => mockDatabase.insert(any(), any()))
          .thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(() => dataSourceSQLite.createExercise(tExercise),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('getExercise', () {
    const tId = 1;

    test(
      'should return Exercise from SQLite Database when there is one matching the id',
      () async {
        // Arrange: Mock the query response
        when(() => mockDatabase.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => [
              {
                'id': 1,
                'name': 'Squat',
                'image_name': 'squat.png',
                'description': 'A lower body exercise'
              }
            ]);

        // Act
        final result = await dataSourceSQLite.getExercise(tId);

        // Assert
        expect(result.id, tId);
        expect(result.name, 'Squat');
        expect(result.imageName, 'squat.png');
        expect(result.description, 'A lower body exercise');
      },
    );

    test('should throw a DatabaseException when query fails', () async {
      // Arrange: Mock the database query to throw an exception
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(() => dataSourceSQLite.getExercise(1),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('fetchExercises', () {
    test(
      'should return a list of all Exercises from SQLite Database',
      () async {
        // Arrange: Mock the query response
        when(() => mockDatabase.query(any())).thenAnswer((_) async => [
              {
                'id': 1,
                'name': 'Squat',
                'image_name': 'squat.png',
                'description': 'A lower body exercise'
              },
              {
                'id': 2,
                'name': 'Push-up',
                'image_name': 'pushup.png',
                'description': 'An upper body exercise'
              }
            ]);

        // Act
        final result = await dataSourceSQLite.fetchExercises();

        // Assert
        expect(result.length, 2); // We expect two exercises in the list
        expect(result[0].name, 'Squat');
        expect(result[1].name, 'Push-up');
      },
    );

    test('should throw a DatabaseException when query fails', () async {
      // Arrange: Mock the database query to throw an exception
      when(() => mockDatabase.query(any())).thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(() => dataSourceSQLite.fetchExercises(),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('updateExercise', () {
    const tExercise = Exercise(
      id: 1,
      name: 'Updated Squat',
      description: 'An updated lower body exercise',
      imageName: 'updated_squat.png',
    );

    test(
      'should update the Exercise in SQLite Database when a valid exercise is provided',
      () async {
        // Arrange: Mock the update response
        when(() => mockDatabase.update(
              any(),
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => 1);

        // Act
        await dataSourceSQLite.updateExercise(tExercise);

        // Assert
        verify(() => mockDatabase.update(
              any(),
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).called(1);
      },
    );

    test('should throw a DatabaseException when update fails', () async {
      // Arrange: Mock the update to throw an exception
      when(() => mockDatabase.update(
            any(),
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(() => dataSourceSQLite.updateExercise(tExercise),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('deleteExercise', () {
    const tExercise = Exercise(
      id: 1,
      name: 'Squat',
      description: 'A lower body exercise',
      imageName: 'squat.png',
    );

    test(
      'should delete the Exercise from SQLite Database when a valid exercise is provided',
      () async {
        // Arrange: Mock the delete response
        when(() => mockDatabase.delete(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) async => 1);

        // Act
        await dataSourceSQLite.deleteExercise(tExercise);

        // Assert
        verify(() => mockDatabase.delete(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).called(1);
      },
    );

    test('should throw a DatabaseException when delete fails', () async {
      // Arrange: Mock the delete to throw an exception
      when(() => mockDatabase.delete(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenThrow(LocalDatabaseException());

      // Act & Assert
      expect(() => dataSourceSQLite.deleteExercise(tExercise),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}
