import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
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

class Params extends Equatable {
  final int id;

  const Params({required this.id});

  @override
  List<Object> get props => [id];
}
