import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';

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
