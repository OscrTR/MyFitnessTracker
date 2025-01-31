import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_run_location.dart';
import '../../domain/entities/history_entry.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HistoryEntry>> createHistoryEntry(
      HistoryEntry historyEntryToCreate) async {
    try {
      final createdHistoryEntry =
          await localDataSource.createHistoryEntry(historyEntryToCreate);
      return Right(createdHistoryEntry);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, HistoryEntry>> getHistoryEntry(int id) async {
    try {
      return Right(await localDataSource.getHistoryEntry(id));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> fetchHistoryEntries() async {
    try {
      return Right(await localDataSource.fetchHistoryEntries());
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, HistoryEntry>> updateHistoryEntry(
      HistoryEntry historyEntryToUpdate) async {
    try {
      final updatedExercise =
          await localDataSource.updateHistoryEntry(historyEntryToUpdate);
      return Right(updatedExercise);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistoryEntry(int id) async {
    try {
      await localDataSource.deleteHistoryEntry(id);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkIfRecentEntry(int id) async {
    try {
      return Right(await localDataSource.checkIfRecentEntry(id));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<RunLocation>>> fetchHistoryRunLocations() async {
    try {
      return Right(await localDataSource.fetchHistoryRunLocations());
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
