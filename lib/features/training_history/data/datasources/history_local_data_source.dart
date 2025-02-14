import 'package:my_fitness_tracker/features/training_history/domain/entities/history_run_location.dart';

import '../models/history_entry_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/history_entry.dart';

abstract class HistoryLocalDataSource {
  /// Query the local database and adds the history entry. Return the created entry.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<HistoryEntryModel> createHistoryEntry(
      HistoryEntry historyEntryToCreate);

  /// Query the local database and return the history entry with the matching training_exercise_id.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<HistoryEntryModel> getHistoryEntry(int id);

  /// Query the local database and return the list of history entries.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<List<HistoryEntryModel>> fetchHistoryEntries(
      DateTime startDate, DateTime endDate);

  /// Query the local database and update the history entry. Return the updated entry.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<HistoryEntryModel> updateHistoryEntry(
      HistoryEntry historyEntryToUpdate);

  /// Query the local database and delete the history entry.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<void> deleteHistoryEntry(int id);

  /// Query the local database and check if there is a history entry from 2 hours ago or less.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<bool> checkIfRecentEntry(int id);

  /// Query the local database and return the list of run locations.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<List<RunLocation>> fetchHistoryRunLocations();
}

class SQLiteHistoryLocalDataSource implements HistoryLocalDataSource {
  final Database database;

  SQLiteHistoryLocalDataSource({required this.database});

  @override
  Future<HistoryEntryModel> createHistoryEntry(
      HistoryEntry historyEntryToCreate) async {
    try {
      final model = HistoryEntryModel(
        trainingId: historyEntryToCreate.trainingId,
        trainingType: historyEntryToCreate.trainingType,
        trainingExerciseId: historyEntryToCreate.trainingExerciseId,
        trainingExerciseType: historyEntryToCreate.trainingExerciseType,
        setNumber: historyEntryToCreate.setNumber,
        multisetSetNumber: historyEntryToCreate.multisetSetNumber,
        date: historyEntryToCreate.date,
        weight: historyEntryToCreate.weight,
        reps: historyEntryToCreate.reps,
        duration: historyEntryToCreate.duration,
        distance: historyEntryToCreate.distance,
        pace: historyEntryToCreate.pace,
        calories: historyEntryToCreate.calories,
        trainingNameAtTime: historyEntryToCreate.trainingNameAtTime,
        exerciseNameAtTime: historyEntryToCreate.exerciseNameAtTime,
        intensity: historyEntryToCreate.intensity,
        exerciseId: historyEntryToCreate.exerciseId,
        multisetId: historyEntryToCreate.multisetId,
      );

      final values = model.toJson();

      final id = await database.insert('history', values);

      return HistoryEntryModel(
        id: id,
        trainingId: historyEntryToCreate.trainingId,
        trainingType: historyEntryToCreate.trainingType,
        trainingExerciseId: historyEntryToCreate.trainingExerciseId,
        trainingExerciseType: historyEntryToCreate.trainingExerciseType,
        setNumber: historyEntryToCreate.setNumber,
        multisetSetNumber: historyEntryToCreate.multisetSetNumber,
        date: historyEntryToCreate.date,
        weight: historyEntryToCreate.weight,
        reps: historyEntryToCreate.reps,
        duration: historyEntryToCreate.duration,
        distance: historyEntryToCreate.distance,
        pace: historyEntryToCreate.pace,
        calories: historyEntryToCreate.calories,
        trainingNameAtTime: historyEntryToCreate.trainingNameAtTime,
        exerciseNameAtTime: historyEntryToCreate.exerciseNameAtTime,
        intensity: historyEntryToCreate.intensity,
        exerciseId: historyEntryToCreate.exerciseId,
        multisetId: historyEntryToCreate.multisetId,
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<HistoryEntryModel> getHistoryEntry(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'history',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return HistoryEntryModel.fromJson(maps.first);
      } else {
        throw Exception('Entry not found');
      }
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<List<HistoryEntryModel>> fetchHistoryEntries(
      DateTime startDate, DateTime endDate) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'history',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );

      final result = List.generate(maps.length, (i) {
        return HistoryEntryModel.fromJson(maps[i]);
      });

      return result;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<bool> checkIfRecentEntry(int id) async {
    try {
      final twoHoursAgo =
          DateTime.now().millisecondsSinceEpoch - (2 * 60 * 60 * 1000);
      final result = await database.query(
        'history',
        where: 'id = ? AND date > ?',
        whereArgs: [id, twoHoursAgo],
      );

      if (result.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<HistoryEntryModel> updateHistoryEntry(
      HistoryEntry historyEntryToUpdate) async {
    try {
      final historyEntryToUpdateModel = HistoryEntryModel(
        id: historyEntryToUpdate.id,
        trainingId: historyEntryToUpdate.trainingId,
        trainingType: historyEntryToUpdate.trainingType,
        trainingExerciseId: historyEntryToUpdate.trainingExerciseId,
        trainingExerciseType: historyEntryToUpdate.trainingExerciseType,
        setNumber: historyEntryToUpdate.setNumber,
        multisetSetNumber: historyEntryToUpdate.multisetSetNumber,
        date: historyEntryToUpdate.date,
        weight: historyEntryToUpdate.weight,
        reps: historyEntryToUpdate.reps,
        duration: historyEntryToUpdate.duration,
        distance: historyEntryToUpdate.distance,
        pace: historyEntryToUpdate.pace,
        calories: historyEntryToUpdate.calories,
        trainingNameAtTime: historyEntryToUpdate.trainingNameAtTime,
        exerciseNameAtTime: historyEntryToUpdate.exerciseNameAtTime,
        intensity: historyEntryToUpdate.intensity,
        exerciseId: historyEntryToUpdate.exerciseId,
        multisetId: historyEntryToUpdate.multisetId,
      );
      await database.update(
        'history',
        historyEntryToUpdateModel.toJson(),
        where: 'id = ?',
        whereArgs: [historyEntryToUpdate.id],
      );
      return historyEntryToUpdateModel;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteHistoryEntry(int id) async {
    try {
      await database.delete(
        'history',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<List<RunLocation>> fetchHistoryRunLocations() async {
    try {
      final List<Map<String, dynamic>> locations =
          await database.query('run_locations');

      final runLocations =
          locations.map((map) => RunLocation.fromMap(map)).toList();

      return runLocations;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }
}
