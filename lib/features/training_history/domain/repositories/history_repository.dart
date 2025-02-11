import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_run_location.dart';
import '../entities/history_entry.dart';

import '../../../../core/error/failures.dart';

abstract class HistoryRepository {
  Future<Either<Failure, HistoryEntry>> getHistoryEntry(int id);

  Future<Either<Failure, List<HistoryEntry>>> fetchHistoryEntries(
      DateTime startDate, DateTime endDate);

  Future<Either<Failure, HistoryEntry>> createHistoryEntry(
      HistoryEntry historyEntry);

  Future<Either<Failure, HistoryEntry>> updateHistoryEntry(
      HistoryEntry historyEntry);

  Future<Either<Failure, void>> deleteHistoryEntry(int id);

  Future<Either<Failure, bool>> checkIfRecentEntry(int id);

  Future<Either<Failure, List<RunLocation>>> fetchHistoryRunLocations();
}
