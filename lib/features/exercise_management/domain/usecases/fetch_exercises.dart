import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';

class FetchExercises {
  final ExerciseRepository repository;

  FetchExercises(this.repository);

  Future<Either<Failure, List<Exercise>>> execute() async {
    return await repository.fetchExercises();
  }
}
