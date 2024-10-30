import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  unitTesting();
  integrationTesting();
}

void unitTesting() {
  late SQLiteExerciseLocalDataSource dataSourceSQLite;
  late MockDatabase mockDatabase;

  setUp(() async {
    mockDatabase = MockDatabase();
    dataSourceSQLite = SQLiteExerciseLocalDataSource(database: mockDatabase);
  });

  group('createExercise', () {
    final tExercise = Exercise(
      name: 'Deadlift',
      imagePath: 'deadlift.png',
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
        // Verify that the insert was called on the mockDatabase with the expected values
        verify(() => mockDatabase.insert(
              any(),
              {
                'name': tExercise.name,
                'image_path': tExercise.imagePath,
                'description': tExercise.description,
              },
            )).called(1);

        // Verify the returned exercise
        expect(result.name, 'Deadlift');
        expect(result.description, 'A full body exercise');
        expect(result.imagePath, 'deadlift.png');
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
                'image_path': 'squat.png',
                'description': 'A lower body exercise'
              }
            ]);

        // Act
        final result = await dataSourceSQLite.getExercise(tId);

        // Assert
        // Verify that query was called with correct parameters
        verify(() => mockDatabase.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).called(1);

        // Verify the result
        expect(result.id, tId);
        expect(result.name, 'Squat');
        expect(result.imagePath, 'squat.png');
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
                'image_path': 'squat.png',
                'description': 'A lower body exercise'
              },
              {
                'id': 2,
                'name': 'Push-up',
                'image_path': 'pushup.png',
                'description': 'An upper body exercise'
              }
            ]);

        // Act
        final result = await dataSourceSQLite.fetchExercises();

        // Assert
        // Verify that query was called on the database
        verify(() => mockDatabase.query(any())).called(1);

        // Verify the result
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
    final tExercise = Exercise(
      id: 1,
      name: 'Updated Squat',
      description: 'An updated lower body exercise',
      imagePath: 'updated_squat.png',
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
        final result = await dataSourceSQLite.updateExercise(tExercise);

        // Assert
        // Verify that the update was called on the mockDatabase with correct arguments
        verify(() => mockDatabase.update(
              any(),
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).called(1);

        // Verify the result
        expect(result.name, tExercise.name);
        expect(result.description, tExercise.description);
        expect(result.imagePath, tExercise.imagePath);
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
    const tId = 1;

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
        await dataSourceSQLite.deleteExercise(tId);

        // Assert
        // Verify that delete was called on the mockDatabase with correct arguments
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
      expect(() => dataSourceSQLite.deleteExercise(tId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}

void integrationTesting() {
  late SQLiteExerciseLocalDataSource dataSource;
  late Database database;

  setUp(() async {
    // Initialize sqflite_ffi for desktop or testing environment
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Use an in-memory SQLite database for testing
    database = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create the exercises table for testing
    await database.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        image_path TEXT
      )
    ''');

    // Initialize the data source
    dataSource = SQLiteExerciseLocalDataSource(database: database);
  });

  tearDown(() async {
    // Close the database after each test
    await database.close();
  });

  group('createExercise', () {
    final tExercise = Exercise(
      name: 'Squat',
      description: 'A lower body exercise',
      imagePath: 'squat.png',
    );

    test('should insert a new Exercise into the database', () async {
      // Act
      final result = await dataSource.createExercise(tExercise);

      // Assert
      expect(result.name, tExercise.name);
      expect(result.description, tExercise.description);
      expect(result.imagePath, tExercise.imagePath);
      expect(result.id, isNotNull); // Ensure the ID is generated

      // Verify that the data is inserted into the database
      final List<Map<String, dynamic>> exercises =
          await database.query('exercises');
      expect(exercises.length, 1);
      expect(exercises.first['name'], tExercise.name);
    });

    test('should throw LocalDatabaseException on error', () async {
      // Simulate a failure by closing the database prematurely
      await database.close();

      // Act & Assert
      expect(() => dataSource.createExercise(tExercise),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('getExercise', () {
    final tExercise = Exercise(
      id: 1,
      name: 'Squat',
      description: 'A lower body exercise',
      imagePath: 'squat.png',
    );

    setUp(() async {
      // Insert an exercise into the database
      await database.insert('exercises', {
        'id': tExercise.id,
        'name': tExercise.name,
        'description': tExercise.description,
        'image_path': tExercise.imagePath,
      });
    });

    test(
        'should return an Exercise from the database when there is one matching the id',
        () async {
      // Act
      final result = await dataSource.getExercise(1);

      // Assert
      expect(result.id, 1);
      expect(result.name, tExercise.name);
      expect(result.description, tExercise.description);
      expect(result.imagePath, tExercise.imagePath);
    });

    test('should throw LocalDatabaseException when the exercise is not found',
        () async {
      // Act & Assert
      expect(() => dataSource.getExercise(999),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('fetchExercises', () {
    test('should return a list of all Exercises from the database', () async {
      // Arrange: Insert two exercises into the database
      await database.insert('exercises', {
        'name': 'Squat',
        'description': 'A lower body exercise',
        'image_path': 'squat.png',
      });

      await database.insert('exercises', {
        'name': 'Push-up',
        'description': 'An upper body exercise',
        'image_path': 'pushup.png',
      });

      // Act
      final result = await dataSource.fetchExercises();

      // Assert
      expect(result.length, 2);
      expect(result[0].name, 'Squat');
      expect(result[1].name, 'Push-up');
    });

    test('should throw LocalDatabaseException on database query error',
        () async {
      // Simulate an error by closing the database
      await database.close();

      // Act & Assert
      expect(() => dataSource.fetchExercises(),
          throwsA(isA<LocalDatabaseException>()));
    });
  });

  group('updateExercise', () {
    final tExercise = Exercise(
      id: 1,
      name: 'Squat',
      description: 'A lower body exercise',
      imagePath: 'squat.png',
    );

    setUp(() async {
      // Insert an exercise into the database
      await database.insert('exercises', {
        'id': tExercise.id,
        'name': tExercise.name,
        'description': tExercise.description,
        'image_path': tExercise.imagePath,
      });
    });

    test('should update the exercise in the database', () async {
      // Arrange
      final updatedExercise = Exercise(
        id: 1,
        name: 'Updated Squat',
        description: 'Updated lower body exercise',
        imagePath: 'updated_squat.png',
      );

      // Act
      final result = await dataSource.updateExercise(updatedExercise);

      // Assert
      expect(result.id, updatedExercise.id);
      expect(result.name, updatedExercise.name);
      expect(result.description, updatedExercise.description);
      expect(result.imagePath, updatedExercise.imagePath);

      // Verify the exercise is updated in the database
      final List<Map<String, dynamic>> exercises =
          await database.query('exercises');
      expect(exercises.first['name'], 'Updated Squat');
    });
  });

  group('deleteExercise', () {
    const tId = 1;
    final tExercise = Exercise(
      id: 1,
      name: 'Squat',
      description: 'A lower body exercise',
      imagePath: 'squat.png',
    );

    setUp(() async {
      // Insert an exercise into the database
      await database.insert('exercises', {
        'id': tExercise.id,
        'name': tExercise.name,
        'description': tExercise.description,
        'image_path': tExercise.imagePath,
      });
    });

    test('should delete the exercise from the database', () async {
      // Act
      await dataSource.deleteExercise(tId);

      // Assert: Verify the exercise is deleted
      final List<Map<String, dynamic>> exercises =
          await database.query('exercises');
      expect(exercises.isEmpty, true);
    });

    test('should throw LocalDatabaseException on error', () async {
      // Simulate an error by closing the database
      await database.close();

      // Act & Assert
      expect(() => dataSource.deleteExercise(tId),
          throwsA(isA<LocalDatabaseException>()));
    });
  });
}
