import '../models/exercise_model.dart';

import '../../domain/entities/exercise.dart';

abstract class ExerciseLocalDataSource {
  /// Query the local database and return the exercise with the matching id.
  ///
  /// Throws a [DatabaseException] for all error codes.
  Future<ExerciseModel> getExercise(int id);

  /// Query the local database and return the list of exercises.
  ///
  /// Throws a [DatabaseException] for all error codes.
  Future<List<ExerciseModel>> fetchExercises();

  /// Query the local database and adds the exercise. Return the created exercise.
  ///
  /// Throws a [DatabaseException] for all error codes.
  Future<ExerciseModel> createExercise(Exercise exerciseToCreate);

  /// Query the local database and update the exercise. Return the updated exercise.
  ///
  /// Throws a [DatabaseException] for all error codes.
  Future<ExerciseModel> updateExercise(Exercise exerciseToUpdate);

  /// Query the local database and adds the exercise. Return the deleted exercise.
  ///
  /// Throws a [DatabaseException] for all error codes.
  Future<ExerciseModel> deleteExercise(Exercise exerciseToDelete);
}
