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
      final createdTrainingExercise = trainingExercise.copyWith(id: id);
      return TrainingExerciseModel.fromTrainingExercise(
          createdTrainingExercise);
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<void> deleteTrainingExercise(int id) async {
    try {
      await database.delete(
        'trainingExercises',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<List<TrainingExerciseModel>> fetchTrainingExercises(
      int trainingId) async {
    try {
      final List<Map<String, dynamic>> values = await database.query(
        'training_exercises',
        where: 'training_id = ?',
        whereArgs: [trainingId],
      );

      return values.map((map) => TrainingExerciseModel.fromJson(map)).toList();
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<TrainingExerciseModel> updateTrainingExercise(
      TrainingExercise trainingExercise) async {
    try {
      Map<String, dynamic> values =
          (trainingExercise as TrainingExerciseModel).toJson();

      await database.update(
        'training_exercises',
        values,
        where: 'id = ?',
        whereArgs: [trainingExercise.id],
      );
      return trainingExercise;
    } catch (e) {
      throw LocalDatabaseException();
    }
  }
}
