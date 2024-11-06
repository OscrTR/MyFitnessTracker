import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:sqflite/sqflite.dart';

abstract class MultisetLocalDataSource {
  Future<MultisetModel> createMultiset(Multiset multiset);

  Future<List<MultisetModel>> fetchMultisets(int trainingId);

  Future<MultisetModel> updateMultiset(Multiset multiset);

  Future<void> deleteMultiset(int id);
}

class SQLiteMultisetLocalDataSource implements MultisetLocalDataSource {
  final Database database;

  SQLiteMultisetLocalDataSource({required this.database});

  @override
  Future<MultisetModel> createMultiset(Multiset multiset) async {
    try {
      Map<String, dynamic> values = (multiset as MultisetModel).toJson();
      final id = await database.insert('multisets', values);
      for (var trainingExercise in multiset.trainingExercises) {
        // Create a copy of the trainingExercise with the new multisetId
        final createdTrainingExercise =
            trainingExercise.copyWith(multisetId: id);
        final trainingExerciseWithMultisetId =
            TrainingExerciseModel.fromTrainingExercise(createdTrainingExercise);

        // Insert the training exercise into the training_exercises table
        await database.insert(
            'training_exercises', trainingExerciseWithMultisetId.toJson());
      }
      final createdMultiset = multiset.copyWith(id: id);
      return MultisetModel.fromMultiset(createdMultiset);
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<void> deleteMultiset(int id) async {
    try {
      await database.delete(
        'multisets',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<List<MultisetModel>> fetchMultisets(int trainingId) async {
    try {
      final List<Map<String, dynamic>> values = await database.query(
        'multisets',
        where: 'training_id = ?',
        whereArgs: [trainingId],
      );

      return values.map((map) => MultisetModel.fromJson(map)).toList();
    } catch (e) {
      throw LocalDatabaseException();
    }
  }

  @override
  Future<MultisetModel> updateMultiset(Multiset multiset) async {
    try {
      final values = (multiset as MultisetModel).toJson();
      await database.update(
        'multisets',
        values,
        where: 'id = ?',
        whereArgs: [multiset.id],
      );

      // Collect all current training exercise IDs
      final currentTrainingExerciseIds = <int>[];
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
            final newId = await database.insert(
                'training_exercises', trainingExerciseWithMultisetId.toJson());
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

      // Delete orphaned training exercises that are no longer associated with the multiset
      await database.delete(
        'training_exercises',
        where:
            'multiset_id = ? AND id NOT IN (${currentTrainingExerciseIds.join(',')})',
        whereArgs: [multiset.id],
      );

      return MultisetModel.fromMultiset(multiset);
    } catch (e) {
      throw LocalDatabaseException();
    }
  }
}
