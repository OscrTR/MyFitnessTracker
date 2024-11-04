import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';

import '../entities/multiset.dart';

class UpdateMultiset extends Usecase<Multiset, Params> {
  final MultisetRepository repository;

  UpdateMultiset(this.repository);

  @override
  Future<Either<Failure, Multiset>> call(Params params) async {
    try {
      return await repository.updateMultiset(params.multiset);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final Multiset multiset;

  const Params(this.multiset);

  @override
  List<Object?> get props => [multiset];
}
