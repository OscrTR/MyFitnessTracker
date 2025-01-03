import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_entry.dart';
import 'package:my_fitness_tracker/features/training_history/domain/repositories/history_repository.dart';

class CreateHistoryEntry extends Usecase<HistoryEntry, Params> {
  final HistoryRepository repository;

  CreateHistoryEntry(this.repository);

  @override
  Future<Either<Failure, HistoryEntry>> call(Params params) async {
    try {
      return await repository.createHistoryEntry(params.historyEntry);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final HistoryEntry historyEntry;

  const Params(this.historyEntry);

  @override
  List<Object> get props => [historyEntry];
}
