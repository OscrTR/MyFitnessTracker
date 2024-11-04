import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/exercise_repository.dart';

class DeleteExercise extends Usecase<void, Params> {
  final ExerciseRepository repository;

  DeleteExercise(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    try {
      return await repository.deleteExercise(params.id);
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
