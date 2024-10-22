import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late SQLiteExerciseLocalDataSource dataSourceSQLite;
  late Database database;

  sqfliteFfiInit();

  setUp(() async {
    // Use an in-memory SQLite database for testing
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    // Initialize the SQLiteExerciseLocalDataSource with the test database
    dataSourceSQLite = SQLiteExerciseLocalDataSource(database);

    // Create a table for exercises in the test database
    await database.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY,
        name TEXT,
        image_name TEXT,
        description TEXT
      )
    ''');

    // Insert a test exercise into the database
    await database.insert('exercises', {
      'id': 1,
      'name': 'Squat',
      'image_name': 'squat.png',
      'description': 'A lower body exercise'
    });

    await database.insert('exercises', {
      'id': 2,
      'name': 'Push-up',
      'image_name': 'pushup.png',
      'description': 'An upper body exercise'
    });
  });

  tearDown(() async {
    // Close the database after each test
    await database.close();
  });

  group('getExercise', () {
    const tId = 1;

    test(
      'should return Exercise from SQLite Database when there is one matching the id',
      () async {
        // Act
        final result = await dataSourceSQLite.getExercise(tId);
        // Assert
        expect(result.id, tId);
        expect(result.name, 'Squat');
        expect(result.imageName, 'squat.png');
        expect(result.description, 'A lower body exercise');
      },
    );
  });

  group('fetchExercises', () {
    test(
      'should return a list of all Exercises from SQLite Database',
      () async {
        // Act
        final result = await dataSourceSQLite.fetchExercises();
        // Assert
        expect(result.length, 2); // We expect two exercises in the list
        expect(result[0].name, 'Squat');
        expect(result[1].name, 'Push-up');
      },
    );
  });

  group('createExercise', () {
    test(
      'should insert a new Exercise into SQLite Database and return the created ExerciseModel',
      () async {
        // Arrange
        const tExercise = Exercise(
          name: 'Deadlift',
          imageName: 'deadlift.png',
          description: 'A full body exercise',
        );

        // Act
        final result = await dataSourceSQLite.createExercise(tExercise);

        // Assert
        // Verify the returned exercise
        expect(result.name, 'Deadlift');
        expect(result.description, 'A full body exercise');
        expect(result.imageName, 'deadlift.png');
        expect(result.id, isNotNull); // Ensure it has an auto-generated id

        // Verify the exercise is in the database
        final List<Map<String, dynamic>> maps =
            await database.query('exercises');
        expect(maps.length, 3);
        expect(maps.last['name'], 'Deadlift');
      },
    );
  });

  group('deleteExercise', () {
    test(
      'should delete the Exercise from SQLite Database when a valid exercise is provided',
      () async {
        // Arrange
        const tExercise = Exercise(
          id: 1,
          name: 'Squat',
          description: 'A lower body exercise',
          imageName: 'squat.png',
        );

        // Act
        await dataSourceSQLite.deleteExercise(tExercise);

        // Assert
        final result =
            await database.query('exercises', where: 'id = ?', whereArgs: [1]);
        expect(result.isEmpty,
            true); // We expect the exercise with id 1 to be deleted
      },
    );
  });

  group('updateExercise', () {
    test(
      'should update the Exercise in SQLite Database when a valid exercise is provided',
      () async {
        // Arrange
        const tExercise = Exercise(
          id: 1,
          name: 'Updated Squat',
          description: 'An updated lower body exercise',
          imageName: 'updated_squat.png',
        );

        // Act
        await dataSourceSQLite.updateExercise(tExercise);

        // Assert
        final updatedExercise =
            await database.query('exercises', where: 'id = ?', whereArgs: [1]);
        expect(updatedExercise.first['name'], 'Updated Squat');
        expect(updatedExercise.first['description'],
            'An updated lower body exercise');
        expect(updatedExercise.first['image_name'], 'updated_squat.png');
      },
    );
  });
}
