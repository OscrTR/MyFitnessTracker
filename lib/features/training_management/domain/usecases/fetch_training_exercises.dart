import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

class FetchTrainingExercises extends Usecase<List<TrainingExercise>, Params> {
  final TrainingExerciseRepository repository;

  FetchTrainingExercises(this.repository);

  @override
  Future<Either<Failure, List<TrainingExercise>>> call(params) async {
    return await repository.fetchTrainingExercises(params.trainingId);
  }
}

class Params extends Equatable {
  final int trainingId;

  const Params({required this.trainingId});

  @override
  List<Object?> get props => [trainingId];
}
