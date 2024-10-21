import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class CreateExercise {
  final ExerciseRepository repository;

  CreateExercise(this.repository);

  Future<Either<Failure, Exercise>> execute(
      {required Exercise exercise}) async {
    return await repository.createExercise(exercise);
  }
}
