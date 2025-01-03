import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_entry.dart';
import 'package:my_fitness_tracker/features/training_history/domain/repositories/history_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class FetchHistoryEntries extends Usecase<List<HistoryEntry>, void> {
  final HistoryRepository repository;

  FetchHistoryEntries(this.repository);

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(void params) async {
    try {
      return await repository.fetchHistoryEntries();
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}
