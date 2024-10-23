import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
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

class Params extends Equatable {
  final Exercise exercise;

  const Params({required this.exercise});

  @override
  List<Object> get props => [exercise];
}
