import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_exercise.dart';
import '../models/multiset_model.dart';
import '../models/training_exercise_model.dart';
import '../models/training_model.dart';

abstract class TrainingLocalDataSource {
  Future<void> createTraining(Training training);

  Future<List<TrainingModel>> fetchTrainings();

  Future<TrainingModel> getTraining(int trainingId);

  Future<void> updateTraining(Training training);

  Future<void> deleteTraining(int id);
}

class SQLiteTrainingLocalDataSource implements TrainingLocalDataSource {
  final Database database;

  SQLiteTrainingLocalDataSource({required this.database});

  @override
  Future<void> createTraining(Training training) async {
    try {
      return await _runInTransaction((txn) async {
        final trainingId = await _insertOrUpdateTraining(
          TrainingModel.fromTraining(training),
          txn,
        );

        await _manageMultisetsAndExercises(training, trainingId, txn);
      });
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteTraining(int trainingId) async {
    try {
      await database.transaction((txn) async {
        await txn.delete(
          'trainings',
          where: 'id = ?',
          whereArgs: [trainingId],
        );
      });
    } catch (e) {
      throw LocalDatabaseException(
          'Failed to delete training: ${e.toString()}');
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
      Future<Map<String, dynamic>> getTrainingBasicInfo(int trainingId) async {
        final queryResult = await database.query(
          'trainings',
          where: 'id = ?',
          whereArgs: [trainingId],
        );

        if (queryResult.isNotEmpty) {
          final row = queryResult.first;
          return {
            'id': row['id'],
            'name': row['name'],
            'type': row['type'],
            'is_selected': row['is_selected'],
            'multisets': [],
            'training_exercises': [],
            'training_days': row['training_days'],
          };
        } else {
          throw Exception('Training not found');
        }
      }

      Future<List<Map<String, dynamic>>> fetchMultisets(int trainingId) async {
        final queryResult = await database.query(
          'multisets',
          where: 'training_id = ?',
          whereArgs: [trainingId],
        );

        return queryResult.map((row) {
          return {
            'id': row['id'],
            'training_id': row['training_id'],
            'sets': row['sets'],
            'set_rest': row['set_rest'],
            'multiset_rest': row['multiset_rest'],
            'special_instructions': row['special_instructions'],
            'objectives': row['objectives'],
            'position': row['position'],
            'training_exercises': [],
            'key': row['key'],
          };
        }).toList();
      }

      Future<List<Map<String, dynamic>>> fetchTrainingExercises(
          int trainingId) async {
        final queryResult = await database.query(
          'training_exercises',
          where: 'training_id = ?',
          whereArgs: [trainingId],
        );

        return queryResult.map((row) {
          return {
            'id': row['id'],
            'training_id': row['training_id'],
            'multiset_id': row['multiset_id'],
            'exercise_id': row['exercise_id'],
            'name': row['name'],
            'description': row['description'],
            'imagePath': row['imagePath'],
            'training_exercise_type': row['training_exercise_type'],
            'sets': row['sets'],
            'is_sets_in_reps': row['is_sets_in_reps'],
            'min_reps': row['min_reps'],
            'max_reps': row['max_reps'],
            'actual_reps': row['actual_reps'],
            'duration': row['duration'],
            'set_rest': row['set_rest'],
            'exercise_rest': row['exercise_rest'],
            'auto_start': row['auto_start'],
            'run_exercise_target': row['run_exercise_target'],
            'target_distance': row['target_distance'],
            'target_duration': row['target_duration'],
            'is_target_pace_selected': row['is_target_pace_selected'],
            'target_pace': row['target_pace'],
            'intervals': row['intervals'],
            'is_interval_in_distance': row['is_interval_in_distance'],
            'interval_distance': row['interval_distance'],
            'interval_duration': row['interval_duration'],
            'interval_rest': row['interval_rest'],
            'special_instructions': row['special_instructions'],
            'objectives': row['objectives'],
            'position': row['position'],
            'key': row['key'],
          };
        }).toList();
      }

      final trainingMap = await getTrainingBasicInfo(trainingId);
      final multisets = await fetchMultisets(trainingId);
      final trainingExercises = await fetchTrainingExercises(trainingId);

      // Organize exercises within multisets and as standalone exercises
      for (var exercise in trainingExercises) {
        final multisetId = exercise['multiset_id'];
        if (multisetId == null) {
          // If no multiset, add directly to the training exercises list
          (trainingMap['training_exercises'] as List).add(exercise);
        } else {
          // Otherwise, find the multiset and add the exercise there
          final multiset = multisets.firstWhere((m) => m['id'] == multisetId);
          (multiset['training_exercises'] as List).add(exercise);
        }
      }

      // Add the organized multisets to the training map
      trainingMap['multisets'] = multisets;
      return TrainingModel.fromJson(trainingMap);
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateTraining(Training training) async {
    try {
      return await _runInTransaction((txn) async {
        final trainingId = training.id!;
        await _insertOrUpdateTraining(
          TrainingModel.fromTraining(training),
          txn,
        );

        await _manageMultisetsAndExercises(training, trainingId, txn,
            isUpdate: true);
      });
    } catch (e) {
      throw LocalDatabaseException(
          'Failed to update training: ${e.toString()}');
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
    // Create/update multisets and add their id in a list to keep
    final currentMultisetsIds =
        await _handleMultisets(training, trainingId, txn, isUpdate);
    // Create/update trainingExercises and add their id in a list to keep
    final currentTrainingExerciseIds = await _handleTrainingExercises(
        training.trainingExercises, trainingId, null, txn);

    if (isUpdate) {
      // Delete multisets that have the training_id but are not in currentMultisetsIds
      await _cleanupUnused(
          'multisets', 'training_id', trainingId, currentMultisetsIds, txn);
      // Delete trainingExercises that have the training_id and no multiset but are not in currentTrainingExerciseIds
      await txn.delete(
        'training_exercises',
        where:
            'training_id = ? AND multiset_id IS NULL AND id NOT IN (${currentTrainingExerciseIds.join(',')})',
        whereArgs: [trainingId],
      );
      // Delete training exercises associated to deleted multiset
      await txn.delete(
        'training_exercises',
        where:
            'training_id = ? AND multiset_id IS NOT NULL AND multiset_id NOT IN (${currentMultisetsIds.join(',')})',
        whereArgs: [trainingId],
      );
    }
  }

  Future<List<int>> _handleMultisets(Training training, int trainingId,
      DatabaseExecutor txn, bool isUpdate) async {
    final currentMultisetsIds = <int>[];

    for (var multiset in training.multisets) {
      final multisetWithTrainingId =
          MultisetModel.fromMultisetWithId(multiset, trainingId);
      final multisetId = await _insertOrUpdate(
          'multisets', multisetWithTrainingId.toJson(), multiset.id, txn);
      currentMultisetsIds.add(multisetId);

      await _handleTrainingExercises(
          multiset.trainingExercises!, trainingId, multisetId, txn);
    }

    return currentMultisetsIds;
  }

  Future<List<int>> _handleTrainingExercises(List<TrainingExercise> exercises,
      int trainingId, int? multisetId, DatabaseExecutor txn) async {
    final currentTrainingExerciseIds = <int>[];

    for (var exercise in exercises) {
      final exerciseWithIds = TrainingExerciseModel.fromTrainingExercisewithId(
        exercise,
        trainingId: trainingId,
        multisetId: multisetId,
      );

      final exerciseId = await _insertOrUpdate(
          'training_exercises', exerciseWithIds.toJson(), exercise.id, txn);
      currentTrainingExerciseIds.add(exerciseId);
    }

    if (multisetId != null) {
      // Delete trainingExercises that have the training_id and the multiset_id but are not in currentTrainingExerciseIds
      await txn.delete(
        'training_exercises',
        where:
            'training_id = ? AND multiset_id = ? AND id NOT IN (${currentTrainingExerciseIds.join(',')})',
        whereArgs: [trainingId, multisetId],
      );
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
