import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';

import '../../../../core/usecases/usecase.dart';

class CreateMultiset extends Usecase<Multiset, Params> {
  final MultisetRepository repository;

  CreateMultiset(this.repository);

  @override
  Future<Either<Failure, Multiset>> call(Params params) async {
    try {
      final multisetResult = await repository.createMultiset(params.multiset);
      return multisetResult;
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
