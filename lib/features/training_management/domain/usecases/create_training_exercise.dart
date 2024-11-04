import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training_exercise.dart.dart';

class CreateTrainingExercise extends Usecase<TrainingExercise, Params> {
  final TrainingExerciseRepository repository;

  CreateTrainingExercise(this.repository);

  @override
  Future<Either<Failure, TrainingExercise>> call(Params params) async {
    try {
      return await repository.createTrainingExercise(params.trainingExercise);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final TrainingExercise trainingExercise;

  const Params(this.trainingExercise);

  @override
  List<Object?> get props => [trainingExercise];
}
