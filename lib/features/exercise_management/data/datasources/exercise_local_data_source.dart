import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exercise.dart';
import '../models/exercise_model.dart';

abstract class ExerciseLocalDataSource {
  /// Query the local database and adds the exercise. Return the created exercise.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<ExerciseModel> createExercise(Exercise exerciseToCreate);

  /// Query the local database and return the exercise with the matching id.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<ExerciseModel> getExercise(int id);

  /// Query the local database and return the list of exercises.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<List<ExerciseModel>> fetchExercises();

  /// Query the local database and update the exercise. Return the updated exercise.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<ExerciseModel> updateExercise(Exercise exerciseToUpdate);

  /// Query the local database and delete the exercise.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<void> deleteExercise(int id);
}

class SQLiteExerciseLocalDataSource implements ExerciseLocalDataSource {
  final Database database;

  SQLiteExerciseLocalDataSource({required this.database});

  @override
  Future<ExerciseModel> createExercise(Exercise exerciseToCreate) async {
    try {
      final model = ExerciseModel(
          name: exerciseToCreate.name,
          imagePath: exerciseToCreate.imagePath,
          description: exerciseToCreate.description,
          exerciseType: exerciseToCreate.exerciseType);
      final values = model.toJson();
      // Insert the exercise into the database and get its generated ID
      final id = await database.insert('exercises', values);

      // Return the created exercise with the newly generated ID
      return ExerciseModel(
        id: id,
        name: exerciseToCreate.name,
        imagePath: exerciseToCreate.imagePath,
        description: exerciseToCreate.description,
        exerciseType: exerciseToCreate.exerciseType,
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<ExerciseModel> getExercise(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'exercises',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return ExerciseModel.fromJson(maps.first);
      } else {
        throw Exception('Exercise not found');
      }
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<List<ExerciseModel>> fetchExercises() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('exercises');

      final result = List.generate(maps.length, (i) {
        return ExerciseModel.fromJson(maps[i]);
      });

      return result;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<ExerciseModel> updateExercise(Exercise exerciseToUpdate) async {
    try {
      final model = ExerciseModel(
          id: exerciseToUpdate.id,
          name: exerciseToUpdate.name,
          imagePath: exerciseToUpdate.imagePath,
          description: exerciseToUpdate.description,
          exerciseType: exerciseToUpdate.exerciseType);
      final values = model.toJson();
      await database.update(
        'exercises',
        values,
        where: 'id = ?',
        whereArgs: [exerciseToUpdate.id],
      );
      return model;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteExercise(int id) async {
    try {
      await database.delete(
        'exercises',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }
}
