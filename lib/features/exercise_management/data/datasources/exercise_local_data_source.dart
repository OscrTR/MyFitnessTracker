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

  /// Query the local database and adds the exercise. Return the deleted exercise.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<ExerciseModel> deleteExercise(Exercise exerciseToDelete);
}

class SQLiteExerciseLocalDataSource implements ExerciseLocalDataSource {
  final Database database;

  SQLiteExerciseLocalDataSource({required this.database});

  @override
  Future<ExerciseModel> createExercise(Exercise exerciseToCreate) async {
    try {
      // Insert the exercise into the database and get its generated ID
      final id = await database.insert('exercises', {
        'name': exerciseToCreate.name,
        'image_name': exerciseToCreate.imageName,
        'description': exerciseToCreate.description,
      });

      // Return the created exercise with the newly generated ID
      return ExerciseModel(
        id: id,
        name: exerciseToCreate.name,
        imageName: exerciseToCreate.imageName,
        description: exerciseToCreate.description,
      );
    } catch (e) {
      throw LocalDatabaseException();
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
      throw LocalDatabaseException();
    }
  }

  @override
  Future<List<ExerciseModel>> fetchExercises() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('exercises');

      return List.generate(maps.length, (i) {
        return ExerciseModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<ExerciseModel> updateExercise(Exercise exerciseToUpdate) async {
    try {
      final exerciseToUpdateModel = ExerciseModel(
        id: exerciseToUpdate.id,
        name: exerciseToUpdate.name,
        imageName: exerciseToUpdate.imageName,
        description: exerciseToUpdate.description,
      );
      await database.update(
        'exercises',
        exerciseToUpdateModel.toJson(),
        where: 'id = ?',
        whereArgs: [exerciseToUpdate.id],
      );
      return exerciseToUpdateModel;
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<ExerciseModel> deleteExercise(Exercise exerciseToDelete) async {
    try {
      await database.delete(
        'exercises',
        where: 'id = ?',
        whereArgs: [exerciseToDelete.id],
      );

      return ExerciseModel(
        id: exerciseToDelete.id,
        name: exerciseToDelete.name,
        imageName: exerciseToDelete.imageName,
        description: exerciseToDelete.description,
      );
    } catch (e) {
      throw LocalDatabaseException();
    }
  }
}
