import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:sqflite/sqflite.dart';

abstract class TrainingLocalDataSource {
  Future<TrainingModel> createTraining(Training training);

  Future<List<TrainingModel>> fetchTrainings();

  Future<TrainingModel> getTraining(int trainingId);

  Future<TrainingModel> updateTraining(Training training);

  Future<void> deleteTraining(int id);
}

class SQLiteTrainingLocalDataSource implements TrainingLocalDataSource {
  final Database database;

  SQLiteTrainingLocalDataSource({required this.database});

  @override
  Future<TrainingModel> createTraining(Training training) async {
    try {
      final values = (training as TrainingModel).toJson();
      final trainingId = await database.insert('trainings', values);
      for (var multiset in training.multisets) {
        final createdMultiset = multiset.copyWith(trainingId: trainingId);
        final multisetWithTrainingId =
            MultisetModel.fromMultiset(createdMultiset);
        final multisetId =
            await database.insert('multisets', multisetWithTrainingId.toJson());

        for (var trainingExercise in multiset.trainingExercises) {
          final createdTrainingExercise = trainingExercise.copyWith(
              trainingId: trainingId, multisetId: multisetId);
          final trainingExerciseWithMultisetId =
              TrainingExerciseModel.fromTrainingExercise(
                  createdTrainingExercise);

          await database.insert(
              'training_exercises', trainingExerciseWithMultisetId.toJson());
        }
      }

      for (var trainingExercise in training.trainingExercises) {
        final createdTrainingExercise =
            trainingExercise.copyWith(trainingId: trainingId);
        final trainingExerciseWithMultisetId =
            TrainingExerciseModel.fromTrainingExercise(createdTrainingExercise);

        await database.insert(
            'training_exercises', trainingExerciseWithMultisetId.toJson());
      }
      final createdTraining = training.copyWith(id: trainingId);
      return TrainingModel.fromMultiset(createdTraining);
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<void> deleteTraining(int id) async {
    try {
      await database.delete(
        'trainings',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<List<TrainingModel>> fetchTrainings() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('trainings');
      return maps.map((map) => TrainingModel.fromJson(map)).toList();
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<TrainingModel> getTraining(int trainingId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'trainings',
        where: 'id = ?',
        whereArgs: [trainingId],
      );
      if (maps.isNotEmpty) {
        return TrainingModel.fromJson(maps.first);
      } else {
        throw LocalDatabaseException();
      }
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<TrainingModel> updateTraining(Training training) async {
    try {
      final values = (training as TrainingModel).toJson();
      await database.update(
        'trainings',
        values,
        where: 'id = ?',
        whereArgs: [training.id],
      );
      final currentTrainingExerciseIds = <int>[];
      final currentMultisetsIds = <int>[];

      for (var multiset in training.multisets) {
        // Add trainingId to multiset
        Multiset createdMultisetWithTrainingId =
            multiset.copyWith(trainingId: training.id);
        final multisetWithTrainingId =
            MultisetModel.fromMultiset(createdMultisetWithTrainingId);

        if (multiset.id != null) {
          // Attempt to update existing multiset
          final rowsUpdated = await database.update(
            'multisets',
            multisetWithTrainingId.toJson(),
            where: 'id = ?',
            whereArgs: [multiset.id],
          );
          if (rowsUpdated == 0) {
            // If no rows were updated, insert as new (in case id was not found)
            final newId = await database.insert(
                'multisets', multisetWithTrainingId.toJson());
            currentMultisetsIds.add(newId);
            // Update th current multisetObjecton which trainingExercises will be iterated on
            createdMultisetWithTrainingId =
                createdMultisetWithTrainingId.copyWith(id: newId);
          } else {
            currentMultisetsIds.add(multiset.id!);
          }
        } else {
          // Insert new multiset if it has no id
          final newId = await database.insert(
              'multisets', multisetWithTrainingId.toJson());
          currentMultisetsIds.add(newId);
          // Update the current multisetObject on which trainingExercises will be iterated on
          createdMultisetWithTrainingId =
              createdMultisetWithTrainingId.copyWith(id: newId);
        }
        for (var trainingExercise in multiset.trainingExercises) {
          final createdtrainingExerciseWithMultisetId =
              trainingExercise.copyWith(multisetId: multiset.id);
          final trainingExerciseWithMultisetId =
              TrainingExerciseModel.fromTrainingExercise(
                  createdtrainingExerciseWithMultisetId);

          if (trainingExercise.id != null) {
            // Attempt to update existing training exercise
            final rowsUpdated = await database.update(
              'training_exercises',
              trainingExerciseWithMultisetId.toJson(),
              where: 'id = ?',
              whereArgs: [trainingExercise.id],
            );
            if (rowsUpdated == 0) {
              // If no rows were updated, insert as new (in case id was not found)
              final newId = await database.insert('training_exercises',
                  trainingExerciseWithMultisetId.toJson());
              currentTrainingExerciseIds.add(newId);
            } else {
              currentTrainingExerciseIds.add(trainingExercise.id!);
            }
          } else {
            // Insert new training exercise if it has no id
            final newId = await database.insert(
                'training_exercises', trainingExerciseWithMultisetId.toJson());
            currentTrainingExerciseIds.add(newId);
          }
        }
        await database.delete(
          'training_exercises',
          where:
              'multiset_id = ? AND id NOT IN (${currentTrainingExerciseIds.join(',')})',
          whereArgs: [multiset.id],
        );
      }

      await database.delete(
        'multisets',
        where:
            'training_id = ? AND id NOT IN (${currentMultisetsIds.join(',')})',
        whereArgs: [training.id],
      );

      for (var trainingExercise in training.trainingExercises) {
        final createdtrainingExerciseWithTrainingId =
            trainingExercise.copyWith(trainingId: training.id);
        final trainingExerciseWithTrainingId =
            TrainingExerciseModel.fromTrainingExercise(
                createdtrainingExerciseWithTrainingId);

        if (trainingExercise.id != null) {
          // Attempt to update existing training exercise
          final rowsUpdated = await database.update(
            'training_exercises',
            trainingExerciseWithTrainingId.toJson(),
            where: 'id = ?',
            whereArgs: [trainingExercise.id],
          );
          if (rowsUpdated == 0) {
            // If no rows were updated, insert as new (in case id was not found)
            final newId = await database.insert(
                'training_exercises', trainingExerciseWithTrainingId.toJson());
            currentTrainingExerciseIds.add(newId);
          } else {
            currentTrainingExerciseIds.add(trainingExercise.id!);
          }
        } else {
          // Insert new training exercise if it has no id
          final newId = await database.insert(
              'training_exercises', trainingExerciseWithTrainingId.toJson());
          currentTrainingExerciseIds.add(newId);
        }
      }

      // Delete orphaned training exercises that are no longer associated with the multiset
      await database.delete(
        'training_exercises',
        where:
            'training_id = ? AND id NOT IN (${currentTrainingExerciseIds.join(',')})',
        whereArgs: [training.id],
      );

      return TrainingModel.fromMultiset(training);
    } catch (e) {
      throw LocalDatabaseException();
    }
  }
}
