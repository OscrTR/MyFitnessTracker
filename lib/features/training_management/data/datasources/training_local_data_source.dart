import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/training_exercise.dart';

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
      return await _runInTransaction((txn) async {
        final trainingId = await _insertOrUpdateTraining(
          TrainingModel.fromTraining(training),
          txn,
        );

        await _manageMultisetsAndExercises(training, trainingId, txn);
        return TrainingModel.fromTraining(training.copyWith(id: trainingId));
      });
    } catch (e) {
      throw LocalDatabaseException(e.toString());
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
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<List<TrainingModel>> fetchTrainings() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('trainings');
      return maps.map((map) => TrainingModel.fromJson(map)).toList();
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<TrainingModel> getTraining(int trainingId) async {
    try {
      final queryResult = await database.rawQuery('''
      SELECT 
        t.id AS training_id, 
        t.name AS training_name, 
        t.type AS training_type, 
        t.is_selected AS training_is_selected,
        
        m.id AS multiset_id, 
        m.training_id AS multiset_training_id, 
        m.sets AS multiset_sets, 
        m.set_rest AS multiset_set_rest, 
        m.multiset_rest AS multiset_multiset_rest, 
        m.special_instructions AS multiset_special_instructions, 
        m.objectives AS multiset_objectives,

        te.id AS exercise_id,
        te.training_id AS exercise_training_id,
        te.multiset_id AS exercise_multiset_id,
        te.exercise_id AS exercise_exercise_id,
        te.training_exercise_type AS exercise_type,
        te.sets AS exercise_sets,
        te.reps AS exercise_reps,
        te.duration AS exercise_duration,
        te.set_rest AS exercise_set_rest,
        te.exercise_rest AS exercise_rest,
        te.manual_start AS exercise_manual_start,
        te.target_distance AS exercise_target_distance,
        te.target_duration AS exercise_target_duration,
        te.target_rythm AS exercise_target_rythm,
        te.intervals AS exercise_intervals,
        te.interval_distance AS exercise_interval_distance,
        te.interval_duration AS exercise_interval_duration,
        te.interval_rest AS exercise_interval_rest,
        te.special_instructions AS exercise_special_instructions,
        te.objectives AS exercise_objectives,
        
        e.name AS exercise_name,
        e.description AS exercise_description,
        e.image_path AS exercise_image_path

      FROM trainings t
      LEFT JOIN multisets m ON t.id = m.training_id
      LEFT JOIN training_exercises te ON (t.id = te.training_id AND (m.id = te.multiset_id OR te.multiset_id IS NULL))
      LEFT JOIN exercises e ON te.exercise_id = e.id
      WHERE t.id = ?
    ''', [trainingId]);

      if (queryResult.isEmpty) {
        throw LocalDatabaseException(
            'No training found for the id: $trainingId');
      }
      Map<String, dynamic> buildTrainingStructure(
          List<Map<String, dynamic>> rows) {
        // Process the query result into a nested structure
        final trainingMap = <String, dynamic>{};
        final multisetMap = <int, Map<String, dynamic>>{};
        final trainingExercises = <Map<String, dynamic>>[];

        for (final row in queryResult) {
          // Populate training data (only once)
          if (trainingMap.isEmpty) {
            trainingMap['id'] = row['training_id'];
            trainingMap['name'] = row['training_name'];
            trainingMap['type'] = row['training_type'];
            trainingMap['is_selected'] = row['training_is_selected'];
            trainingMap['multisets'] = [];
            trainingMap['training_exercises'] = [];
          }

          // Populate multiset data
          final multisetId = row['multiset_id'] as int?;
          if (multisetId != null && !multisetMap.containsKey(multisetId)) {
            final multiset = {
              'id': multisetId,
              'training_id': row['multiset_training_id'],
              'sets': row['multiset_sets'],
              'set_rest': row['multiset_set_rest'],
              'multiset_rest': row['multiset_multiset_rest'],
              'special_instructions': row['multiset_special_instructions'],
              'objectives': row['multiset_objectives'],
              'training_exercises': []
            };
            multisetMap[multisetId] = multiset;
            trainingMap['multisets'].add(multiset);
          }

          // Populate exercises within multiset or directly for training
          final exerciseId = row['exercise_id'];
          if (exerciseId != null) {
            final exercise = {
              'id': exerciseId,
              'training_id': row['exercise_training_id'],
              'multiset_id': row['exercise_multiset_id'],
              'exercise_id': row['exercise_exercise_id'],
              'name': row['exercise_name'],
              'description': row['exercise_description'],
              'imagePath': row['exercise_image_path'],
              'training_exercise_type': row['exercise_type'],
              'sets': row['exercise_sets'],
              'reps': row['exercise_reps'],
              'duration': row['exercise_duration'],
              'set_rest': row['exercise_set_rest'],
              'exercise_rest': row['exercise_rest'],
              'manual_start': row['exercise_manual_start'],
              'target_distance': row['exercise_target_distance'],
              'target_duration': row['exercise_target_duration'],
              'target_rythm': row['exercise_target_rythm'],
              'intervals': row['exercise_intervals'],
              'interval_distance': row['exercise_interval_distance'],
              'interval_duration': row['exercise_interval_duration'],
              'interval_rest': row['exercise_interval_rest'],
              'special_instructions': row['exercise_special_instructions'],
              'objectives': row['exercise_objectives'],
            };

            if (row['exercise_multiset_id'] == null) {
              trainingExercises.add(exercise);
            } else {
              multisetMap[multisetId]?['training_exercises'].add(exercise);
            }
          }
        }

        // Assign the collected training exercises directly to the training map
        trainingMap['training_exercises'] = trainingExercises;
        return trainingMap;
      }

      // Build and return TrainingModel
      final trainingData = buildTrainingStructure(queryResult);
      return TrainingModel.fromJson(trainingData);
    } catch (e) {
      throw LocalDatabaseException(e.toString());
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

      return TrainingModel.fromTraining(training);
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  Future<T> _runInTransaction<T>(
      Future<T> Function(DatabaseExecutor txn) action) async {
    return await database.transaction((txn) async {
      return await action(txn);
    });
  }

  Future<int> _insertOrUpdateTraining(
      TrainingModel training, DatabaseExecutor txn) async {
    final values = training.toJson();
    if (training.id != null) {
      await txn.update('trainings', values,
          where: 'id = ?', whereArgs: [training.id]);
      return training.id!;
    } else {
      return await txn.insert('trainings', values);
    }
  }

  Future<void> _manageMultisetsAndExercises(
      Training training, int trainingId, DatabaseExecutor txn,
      {bool isUpdate = false}) async {
    final currentMultisetsIds =
        await _handleMultisets(training, trainingId, txn, isUpdate);
    final currentTrainingExerciseIds = await _handleTrainingExercises(
        training.trainingExercises, trainingId, null, txn);

    if (isUpdate) {
      await _cleanupUnused(
          'multisets', 'training_id', trainingId, currentMultisetsIds, txn);
      await _cleanupUnused('training_exercises', 'training_id', trainingId,
          currentTrainingExerciseIds, txn);
    }
  }

  Future<List<int>> _handleMultisets(Training training, int trainingId,
      DatabaseExecutor txn, bool isUpdate) async {
    final currentMultisetsIds = <int>[];

    for (var multiset in training.multisets) {
      final multisetWithTrainingId =
          MultisetModel.fromMultiset(multiset.copyWith(trainingId: trainingId));
      final multisetId = await _insertOrUpdate(
          'multisets', multisetWithTrainingId.toJson(), multiset.id, txn);
      currentMultisetsIds.add(multisetId);

      await _handleTrainingExercises(
          multiset.trainingExercises, trainingId, multisetId, txn);
    }
    return currentMultisetsIds;
  }

  Future<List<int>> _handleTrainingExercises(List<TrainingExercise> exercises,
      int trainingId, int? multisetId, DatabaseExecutor txn) async {
    final currentTrainingExerciseIds = <int>[];

    for (var exercise in exercises) {
      final exerciseWithIds = TrainingExerciseModel.fromTrainingExercise(
        exercise.copyWith(trainingId: trainingId, multisetId: multisetId),
      );
      final exerciseId = await _insertOrUpdate(
          'training_exercises', exerciseWithIds.toJson(), exercise.id, txn);
      currentTrainingExerciseIds.add(exerciseId);
    }
    return currentTrainingExerciseIds;
  }

  Future<int> _insertOrUpdate(String table, Map<String, dynamic> values,
      int? id, DatabaseExecutor txn) async {
    if (id != null) {
      final rowsUpdated =
          await txn.update(table, values, where: 'id = ?', whereArgs: [id]);
      if (rowsUpdated > 0) return id;
    }
    return await txn.insert(table, values);
  }

  Future<void> _cleanupUnused(String table, String column, int parentId,
      List<int> validIds, DatabaseExecutor txn) async {
    await txn.delete(
      table,
      where: '$column = ? AND id NOT IN (${validIds.join(',')})',
      whereArgs: [parentId],
    );
  }
}
