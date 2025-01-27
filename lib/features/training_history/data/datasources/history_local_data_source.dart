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
  Future<List<HistoryEntryModel>> fetchHistoryEntries();

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
}

class SQLiteHistoryLocalDataSource implements HistoryLocalDataSource {
  final Database database;

  SQLiteHistoryLocalDataSource({required this.database});

  @override
  Future<HistoryEntryModel> createHistoryEntry(
      HistoryEntry historyEntryToCreate) async {
    try {
      final id = await database.insert('history', {
        'training_id': historyEntryToCreate.trainingId,
        'training_exercise_id': historyEntryToCreate.trainingExerciseId,
        'set_number': historyEntryToCreate.setNumber,
        'multiset_set_number': historyEntryToCreate.multisetSetNumber,
        'date': historyEntryToCreate.date.millisecondsSinceEpoch,
        'weight': historyEntryToCreate.weight,
        'reps': historyEntryToCreate.reps,
        'duration': historyEntryToCreate.duration,
        'distance': historyEntryToCreate.distance,
        'pace': historyEntryToCreate.pace,
        'calories': historyEntryToCreate.calories
      });

      return HistoryEntryModel(
          id: id,
          trainingId: historyEntryToCreate.trainingId,
          trainingExerciseId: historyEntryToCreate.trainingExerciseId,
          setNumber: historyEntryToCreate.setNumber,
          multisetSetNumber: historyEntryToCreate.multisetSetNumber,
          date: historyEntryToCreate.date,
          weight: historyEntryToCreate.weight,
          reps: historyEntryToCreate.reps,
          duration: historyEntryToCreate.duration,
          distance: historyEntryToCreate.distance,
          pace: historyEntryToCreate.pace,
          calories: historyEntryToCreate.calories);
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
  Future<List<HistoryEntryModel>> fetchHistoryEntries() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('history');

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
          trainingExerciseId: historyEntryToUpdate.trainingExerciseId,
          setNumber: historyEntryToUpdate.setNumber,
          multisetSetNumber: historyEntryToUpdate.multisetSetNumber,
          date: historyEntryToUpdate.date,
          weight: historyEntryToUpdate.weight,
          reps: historyEntryToUpdate.reps,
          duration: historyEntryToUpdate.duration,
          distance: historyEntryToUpdate.distance,
          pace: historyEntryToUpdate.pace,
          calories: historyEntryToUpdate.calories);
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
}
