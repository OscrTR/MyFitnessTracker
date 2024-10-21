import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';

import '../repositories/exercise_repository.dart';

class UpdateExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  UpdateExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    return await repository.updateExercise(params.exercise);
  }
}

class Params {
  final Exercise exercise;

  Params({required this.exercise});
}
