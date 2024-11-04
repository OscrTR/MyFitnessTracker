import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/training_exercise_repository.dart';

class UpdateTrainingExercise extends Usecase<TrainingExercise, Params> {
  final TrainingExerciseRepository repository;

  UpdateTrainingExercise(this.repository);

  @override
  Future<Either<Failure, TrainingExercise>> call(Params params) async {
    try {
      return await repository.updateTrainingExercise(params.trainingExercise);
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
