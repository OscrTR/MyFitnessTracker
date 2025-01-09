import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/muscle.dart';
import '../models/muscle_model.dart';

abstract class MuscleLocalDataSource {
  /// Query the local database and adds the muscle. Return the created muscle.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<MuscleModel> createMuscle(Muscle muscle);

  /// Query the local database and return the muscle with the matching id.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<MuscleModel> getMuscle(int id);

  /// Query the local database and return the list of muscles.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<List<MuscleModel>> fetchMuscles();

  /// Query the local database and update the muscle. Return the updated muscle.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<MuscleModel> updateMuscle(Muscle muscle);

  /// Query the local database and delete the muscle.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<void> deleteMuscle(int id);

  /// Query the local database and assign a muscle to an exercise.
  ///
  /// Throws a [LocalDatabaseException] for all error codes.
  Future<void> assignMuscleToExercise(
      int exerciseId, int muscleId, bool isPrimary);
}

class SQLiteMuscleLocalDataSource implements MuscleLocalDataSource {
  final Database database;

  SQLiteMuscleLocalDataSource({required this.database});

  @override
  Future<MuscleModel> createMuscle(Muscle muscle) async {
    try {
      final muscleModel = MuscleModel.fromMuscle(muscle);
      final id = await database.insert('muscles', muscleModel.toJson());
      return muscleModel.copyWith(id: id);
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteMuscle(int id) async {
    try {
      await database.delete(
        'muscles',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<List<MuscleModel>> fetchMuscles() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('muscles');

      final result = List.generate(maps.length, (i) {
        return MuscleModel.fromJson(maps[i]);
      });

      return result;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<MuscleModel> getMuscle(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'muscles',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return MuscleModel.fromJson(maps.first);
      } else {
        throw Exception('Exercise not found');
      }
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<MuscleModel> updateMuscle(Muscle muscle) async {
    try {
      final muscleModel = MuscleModel.fromMuscle(muscle);
      await database.update(
        'exercises',
        muscleModel.toJson(),
        where: 'id = ?',
        whereArgs: [muscle.id],
      );
      return muscleModel;
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }

  @override
  Future<void> assignMuscleToExercise(
      int exerciseId, int muscleId, bool isPrimary) async {
    try {
      await database.insert(
        'exercise_muscles',
        {
          'exercise_id': exerciseId,
          'muscle_id': muscleId,
          'is_primary': isPrimary ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw LocalDatabaseException(e.toString());
    }
  }
}
