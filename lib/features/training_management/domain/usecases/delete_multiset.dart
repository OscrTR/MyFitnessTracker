import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';

class DeleteMultiset extends Usecase<void, Params> {
  final MultisetRepository repository;

  DeleteMultiset(this.repository);

  @override
  Future<Either<Failure, void>> call(params) async {
    try {
      return await repository.deleteMultiset(params.id);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object?> get props => [id];
}
