import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

class DeleteTrainingExercise extends Usecase<void, Params> {
  final TrainingExerciseRepository repository;

  DeleteTrainingExercise(this.repository);

  @override
  Future<Either<Failure, void>> call(params) async {
    return await repository.deleteTrainingExercise(params.id);
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object?> get props => [id];
}
