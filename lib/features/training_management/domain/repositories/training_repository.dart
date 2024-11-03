import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

import '../../../../core/error/failures.dart';

abstract class TrainingRepository {
  Future<Either<Failure, Training>> getTraining(int id);

  Future<Either<Failure, List<Training>>> fetchTrainings();

  Future<Either<Failure, Training>> createTraining(Training training);

  Future<Either<Failure, Training>> updateTraining(Training training);

  Future<Either<Failure, void>> deleteTraining(int id);
}
