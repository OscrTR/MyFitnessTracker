import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';

class FetchMultisets extends Usecase<List<Multiset>, Params> {
  final MultisetRepository repository;

  FetchMultisets(this.repository);

  @override
  Future<Either<Failure, List<Multiset>>> call(params) async {
    try {
      return await repository.fetchMultisets(params.trainingId);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int trainingId;

  const Params(this.trainingId);

  @override
  List<Object?> get props => [trainingId];
}
