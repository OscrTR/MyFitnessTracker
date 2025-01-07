import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_history/domain/repositories/history_repository.dart';

class CheckRecentEntry extends Usecase<bool, Params> {
  final HistoryRepository repository;

  CheckRecentEntry(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    try {
      return await repository.checkIfRecentEntry(params.id);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object> get props => [id];
}
