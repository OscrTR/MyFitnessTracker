import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/training_exercise.dart';

abstract class TrainingExerciseRepository {
  Future<Either<Failure, List<TrainingExercise>>> fetchTrainingExercises(
      int trainingId);

  Future<Either<Failure, TrainingExercise>> createTrainingExercise(
      TrainingExercise trainingExercise);

  Future<Either<Failure, TrainingExercise>> updateTrainingExercise(
      TrainingExercise trainingExercise);

  Future<Either<Failure, void>> deleteTrainingExercise(int id);
}
