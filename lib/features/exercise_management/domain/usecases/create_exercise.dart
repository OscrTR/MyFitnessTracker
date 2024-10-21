import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class CreateExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  CreateExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    return await repository.createExercise(params.exercise);
  }
}

class Params {
  final Exercise exercise;

  Params({required this.exercise});
}
