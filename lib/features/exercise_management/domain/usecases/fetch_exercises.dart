import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';

class FetchExercises extends Usecase<List<Exercise>, void> {
  final ExerciseRepository repository;

  FetchExercises(this.repository);

  @override
  Future<Either<Failure, List<Exercise>>> call(void params) async {
    return await repository.fetchExercises();
  }
}
