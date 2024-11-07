import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class UpdateExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  UpdateExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    try {
      if (params.exercise.name.isEmpty) {
        return const Left(InvalidNameFailure());
      }

      return await repository.updateExercise(params.exercise);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final Exercise exercise;

  const Params(this.exercise);

  @override
  List<Object> get props => [exercise];
}
