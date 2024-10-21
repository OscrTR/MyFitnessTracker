import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';

import '../repositories/exercise_repository.dart';

class UpdateExercise {
  final ExerciseRepository repository;

  UpdateExercise(this.repository);

  Future<Either<Failure, Exercise>> execute(
      {required Exercise exercise}) async {
    return await repository.updateExercise(exercise);
  }
}
