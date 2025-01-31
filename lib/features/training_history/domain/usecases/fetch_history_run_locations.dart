import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_run_location.dart';
import '../repositories/history_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class FetchHistoryRunLocations extends Usecase<List<RunLocation>, void> {
  final HistoryRepository repository;

  FetchHistoryRunLocations(this.repository);

  @override
  Future<Either<Failure, List<RunLocation>>> call(void params) async {
    try {
      return await repository.fetchHistoryRunLocations();
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}
