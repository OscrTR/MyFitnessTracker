import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';

class DeleteExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  DeleteExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    return await repository.deleteExercise(params.exercise);
  }
}

class Params {
  final Exercise exercise;

  Params({required this.exercise});
}
