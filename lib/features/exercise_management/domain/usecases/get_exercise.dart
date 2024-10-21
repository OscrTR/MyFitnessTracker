import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercise {
  final ExerciseRepository repository;

  GetExercise(this.repository);

  Future<Either<Failure, Exercise>> execute({
    required int id,
  }) async {
    return await repository.getExercise(id);
  }
}
