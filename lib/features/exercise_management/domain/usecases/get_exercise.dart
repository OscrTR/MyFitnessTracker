import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  GetExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    return await repository.getExercise(params.id);
  }
}

class Params {
  final int id;

  Params({required this.id});
}
