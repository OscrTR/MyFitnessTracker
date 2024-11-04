import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite_ffi for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SQLiteDatabaseHelper', () {
    late Database db;

    setUp(() async {
      // Use an in-memory database with sqflite_ffi
      db = await openDatabase(inMemoryDatabasePath, version: 1,
          onCreate: (db, version) async {
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
            type TEXT, 
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
          CREATE TABLE run_exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            training_id INTEGER,
            multiset_id INTEGER,
            target_distance INTEGER,
            target_duration INTEGER,
            target_rythm INTEGER,
            intervals INTEGER,
            interval_distance INTEGER,
            interval_duration INTEGER,
            interval_rest INTEGER,
            FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE,
            FOREIGN KEY(multiset_id) REFERENCES multisets(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE workout_exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            training_id INTEGER,
            multiset_id INTEGER,
            exercise_id INTEGER,
            sets INTEGER,
            reps INTEGER,
            duration INTEGER,
            set_rest INTEGER,
            exercise_rest INTEGER,
            manual_start INTEGER,
            FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE,
            FOREIGN KEY(multiset_id) REFERENCES multisets(id) ON DELETE CASCADE,
            FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE yoga_exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            training_id INTEGER,
            multiset_id INTEGER,
            exercise_id INTEGER,
            sets INTEGER,
            reps INTEGER,
            duration INTEGER,
            set_rest INTEGER,
            exercise_rest INTEGER,
            manual_start INTEGER,
            FOREIGN KEY(training_id) REFERENCES trainings(id) ON DELETE CASCADE,
            FOREIGN KEY(multiset_id) REFERENCES multisets(id) ON DELETE CASCADE,
            FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
          )
        ''');
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('database should be created and open', () async {
      expect(db.isOpen, true);
    });

    test('all tables should exist', () async {
      final tables = [
        'exercises',
        'trainings',
        'multisets',
        'run_exercises',
        'workout_exercises',
        'yoga_exercises'
      ];
      for (final table in tables) {
        final result = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
        expect(result.isNotEmpty, true, reason: '$table table should exist');
      }
    });

    test('can insert and retrieve a training', () async {
      // Insert a sample training
      await db.insert('trainings',
          {'name': 'Morning Workout', 'type': 'Strength', 'is_selected': 1});

      // Retrieve the training
      final result = await db.query('trainings');
      expect(result.length, 1);
      expect(result.first['name'], 'Morning Workout');
    });

    test('can insert and retrieve a multiset', () async {
      // Insert a training to reference
      int trainingId = await db.insert('trainings',
          {'name': 'Circuit Training', 'type': 'Endurance', 'is_selected': 0});

      // Insert a multiset
      await db.insert('multisets', {
        'training_id': trainingId,
        'sets': 4,
        'set_rest': 30,
        'multiset_rest': 60,
        'special_instructions': 'Focus on form',
        'objectives': 'Endurance'
      });

      // Retrieve the multiset
      final result = await db.query('multisets');
      expect(result.length, 1);
      expect(result.first['training_id'], trainingId);
    });

    test('can insert and retrieve a workout exercise', () async {
      int trainingId = await db.insert('trainings',
          {'name': 'Strength Training', 'type': 'Strength', 'is_selected': 1});
      int exerciseId = await db.insert('exercises', {
        'name': 'Squat',
        'description': 'Lower body strength exercise',
        'image_path': '/images/squat.png'
      });

      // Insert a workout exercise
      await db.insert('workout_exercises', {
        'training_id': trainingId,
        'multiset_id': null,
        'exercise_id': exerciseId,
        'sets': 3,
        'reps': 12,
        'duration': 0,
        'set_rest': 30,
        'exercise_rest': 60,
        'manual_start': 0
      });

      // Retrieve the workout exercise
      final result = await db.query('workout_exercises');
      expect(result.length, 1);
      expect(result.first['exercise_id'], exerciseId);
    });

    test(
      'should create and retrieve yoga exercise',
      () async {
        // Arrange
        int trainingId = await db.insert('trainings',
            {'name': 'Yoga Training', 'type': 'Yoga', 'is_selected': 1});
        int exerciseId = await db.insert('exercises', {
          'name': 'Downward dog',
          'description': 'Back exercise',
          'image_path': '/images/downward_dog.png'
        });

        // Act
        await db.insert('yoga_exercises', {
          'training_id': trainingId,
          'multiset_id': null,
          'exercise_id': exerciseId,
          'sets': 1,
          'reps': 1,
          'duration': 30,
          'set_rest': 10,
          'exercise_rest': 10,
          'manual_start': 0
        });

        final result = await db.query('yoga_exercises');

        // Assert
        expect(result.length, 1);
        expect(result.first['exercise_id'], exerciseId);
      },
    );

    test(
      'should create and retrieve a run exercise',
      () async {
        // Arrange
        int trainingId = await db.insert('trainings',
            {'name': 'Run Training', 'type': 'Run', 'is_selected': 1});

        // Act
        await db.insert('run_exercises', {
          'training_id': trainingId,
          'multiset_id': null,
          'target_distance': 5000
        });

        final result = await db.query('run_exercises');

        // Assert
        expect(result.length, 1);
        expect(result.first['target_distance'], 5000);
      },
    );

    test(
      'should update training',
      () async {
        // Arrange
        await db.insert('trainings',
            {'name': 'Morning Workout', 'type': 'Strength', 'is_selected': 1});

        // Act
        await db.update(
          'trainings',
          {
            'name': 'Morning Workout Edit',
            'type': 'Strength',
            'is_selected': 1
          },
          where: 'name = "Morning Workout"',
        );

        final result = await db.query('trainings');

        // Assert
        expect(result.length, 1);
        expect(result.first['name'], 'Morning Workout Edit');
      },
    );

    test('can update a multiset', () async {
      // Arrange: Insert a training and a multiset
      int trainingId = await db.insert('trainings',
          {'name': 'Strength Circuit', 'type': 'Strength', 'is_selected': 0});
      int multisetId = await db.insert('multisets', {
        'training_id': trainingId,
        'sets': 3,
        'set_rest': 30,
        'multiset_rest': 60,
        'special_instructions': 'Initial instructions',
        'objectives': 'Strength'
      });

      // Act: Update the multiset
      await db.update('multisets',
          {'sets': 4, 'special_instructions': 'Updated instructions'},
          where: 'id = ?', whereArgs: [multisetId]);

      // Assert
      final result =
          await db.query('multisets', where: 'id = ?', whereArgs: [multisetId]);
      expect(result.first['sets'], 4);
      expect(result.first['special_instructions'], 'Updated instructions');
    });

    test('can update a workout exercise', () async {
      // Arrange: Insert a training, exercise, and workout exercise
      int trainingId = await db.insert('trainings',
          {'name': 'Workout', 'type': 'Strength', 'is_selected': 1});
      int exerciseId = await db.insert('exercises', {
        'name': 'Push Up',
        'description': 'Upper body',
        'image_path': '/images/push_up.png'
      });
      int workoutExerciseId = await db.insert('workout_exercises', {
        'training_id': trainingId,
        'exercise_id': exerciseId,
        'sets': 3,
        'reps': 10,
        'set_rest': 30,
        'exercise_rest': 60,
        'manual_start': 0
      });

      // Act: Update the workout exercise
      await db.update('workout_exercises', {'sets': 4, 'reps': 12},
          where: 'id = ?', whereArgs: [workoutExerciseId]);

      // Assert
      final result = await db.query('workout_exercises',
          where: 'id = ?', whereArgs: [workoutExerciseId]);
      expect(result.first['sets'], 4);
      expect(result.first['reps'], 12);
    });

    test('can update a yoga exercise', () async {
      // Arrange: Insert a training, exercise, and yoga exercise
      int trainingId = await db.insert('trainings',
          {'name': 'Yoga Session', 'type': 'Yoga', 'is_selected': 1});
      int exerciseId = await db.insert('exercises', {
        'name': 'Downward Dog',
        'description': 'Stretch',
        'image_path': '/images/downward_dog.png'
      });
      int yogaExerciseId = await db.insert('yoga_exercises', {
        'training_id': trainingId,
        'exercise_id': exerciseId,
        'sets': 1,
        'reps': 1,
        'duration': 30,
        'set_rest': 10,
        'exercise_rest': 10
      });

      // Act: Update the yoga exercise
      await db.update('yoga_exercises', {'duration': 60, 'set_rest': 20},
          where: 'id = ?', whereArgs: [yogaExerciseId]);

      // Assert
      final result = await db.query('yoga_exercises',
          where: 'id = ?', whereArgs: [yogaExerciseId]);
      expect(result.first['duration'], 60);
      expect(result.first['set_rest'], 20);
    });

    test('can update a run exercise', () async {
      // Arrange: Insert a training and a run exercise
      int trainingId = await db.insert(
          'trainings', {'name': 'Run', 'type': 'Run', 'is_selected': 1});
      int runExerciseId = await db.insert('run_exercises', {
        'training_id': trainingId,
        'target_distance': 5000,
        'target_duration': 30
      });

      // Act: Update the run exercise
      await db.update(
          'run_exercises', {'target_distance': 10000, 'target_duration': 60},
          where: 'id = ?', whereArgs: [runExerciseId]);

      // Assert
      final result = await db
          .query('run_exercises', where: 'id = ?', whereArgs: [runExerciseId]);
      expect(result.first['target_distance'], 10000);
      expect(result.first['target_duration'], 60);
    });

    test('can delete a training', () async {
      // Arrange: Insert a training
      int trainingId = await db.insert('trainings',
          {'name': 'To Delete', 'type': 'Cardio', 'is_selected': 1});

      // Act: Delete the training
      await db.delete('trainings', where: 'id = ?', whereArgs: [trainingId]);

      // Assert
      final result =
          await db.query('trainings', where: 'id = ?', whereArgs: [trainingId]);
      expect(result.isEmpty, true);
    });

    test('can delete a multiset', () async {
      // Arrange: Insert a training and a multiset
      int trainingId = await db.insert('trainings',
          {'name': 'Multiset Training', 'type': 'Strength', 'is_selected': 1});
      int multisetId = await db.insert(
          'multisets', {'training_id': trainingId, 'sets': 3, 'set_rest': 30});

      // Act: Delete the multiset
      await db.delete('multisets', where: 'id = ?', whereArgs: [multisetId]);

      // Assert
      final result =
          await db.query('multisets', where: 'id = ?', whereArgs: [multisetId]);
      expect(result.isEmpty, true);
    });

    test('can delete a workout exercise', () async {
      // Arrange: Insert a workout exercise
      int trainingId = await db.insert('trainings',
          {'name': 'Workout Training', 'type': 'Strength', 'is_selected': 1});
      int exerciseId = await db.insert('exercises', {
        'name': 'Bench Press',
        'description': 'Chest exercise',
        'image_path': '/images/bench_press.png'
      });
      int workoutExerciseId = await db.insert('workout_exercises', {
        'training_id': trainingId,
        'exercise_id': exerciseId,
        'sets': 3,
        'reps': 12
      });

      // Act: Delete the workout exercise
      await db.delete('workout_exercises',
          where: 'id = ?', whereArgs: [workoutExerciseId]);

      // Assert
      final result = await db.query('workout_exercises',
          where: 'id = ?', whereArgs: [workoutExerciseId]);
      expect(result.isEmpty, true);
    });

    test('can delete a yoga exercise', () async {
      // Arrange: Insert a yoga exercise
      int trainingId = await db.insert('trainings',
          {'name': 'Yoga Training', 'type': 'Yoga', 'is_selected': 1});
      int exerciseId = await db.insert('exercises', {
        'name': 'Child Pose',
        'description': 'Stretching',
        'image_path': '/images/child_pose.png'
      });
      int yogaExerciseId = await db.insert('yoga_exercises', {
        'training_id': trainingId,
        'exercise_id': exerciseId,
        'sets': 1,
        'reps': 1,
        'duration': 60
      });

      // Act: Delete the yoga exercise
      await db.delete('yoga_exercises',
          where: 'id = ?', whereArgs: [yogaExerciseId]);

      // Assert
      final result = await db.query('yoga_exercises',
          where: 'id = ?', whereArgs: [yogaExerciseId]);
      expect(result.isEmpty, true);
    });

    test('can delete a run exercise', () async {
      // Arrange: Insert a run exercise
      int trainingId = await db.insert('trainings',
          {'name': 'Running Session', 'type': 'Run', 'is_selected': 1});
      int runExerciseId = await db.insert('run_exercises', {
        'training_id': trainingId,
        'target_distance': 3000,
        'target_duration': 20
      });

      // Act: Delete the run exercise
      await db
          .delete('run_exercises', where: 'id = ?', whereArgs: [runExerciseId]);

      // Assert
      final result = await db
          .query('run_exercises', where: 'id = ?', whereArgs: [runExerciseId]);
      expect(result.isEmpty, true);
    });
  });
}
