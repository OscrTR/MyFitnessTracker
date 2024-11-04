import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';

abstract class TrainingExerciseLocalDataSource {
  Future<TrainingExerciseModel> createTrainingExercise(
      TrainingExercise trainingExercise);

  Future<List<TrainingExerciseModel>> fetchTrainingExercises(int trainingId);

  Future<TrainingExerciseModel> updateTrainingExercise(
      TrainingExercise trainingExercise);

  Future<void> deleteTrainingExercise(int id);
}

class SQLiteTrainingExerciseLocalDataSource
    implements TrainingExerciseLocalDataSource {
  final Database database;

  SQLiteTrainingExerciseLocalDataSource({required this.database});

  @override
  Future<TrainingExerciseModel> createTrainingExercise(
      TrainingExercise trainingExercise) async {
    try {
      Map<String, dynamic> values =
          (trainingExercise as TrainingExerciseModel).toJson();

      final id = await database.insert('training_exercises', values);
      return trainingExercise.copyWith(id: id) as TrainingExerciseModel;
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<void> deleteTrainingExercise(int id) {
    // TODO: implement deleteTrainingExercise
    throw UnimplementedError();
  }

  @override
  Future<List<TrainingExerciseModel>> fetchTrainingExercises(int trainingId) {
    // TODO: implement fetchTrainingExercise
    throw UnimplementedError();
  }

  @override
  Future<TrainingExerciseModel> updateTrainingExercise(
      TrainingExercise trainingExercise) {
    // TODO: implement updateTrainingExercise
    throw UnimplementedError();
  }
}
