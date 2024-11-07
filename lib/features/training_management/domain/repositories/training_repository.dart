import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/training.dart';

abstract class TrainingRepository {
  Future<Either<Failure, Training>> getTraining(int id);

  Future<Either<Failure, List<Training>>> fetchTrainings();

  Future<Either<Failure, Training>> createTraining(Training training);

  Future<Either<Failure, Training>> updateTraining(Training training);

  Future<Either<Failure, void>> deleteTraining(int id);
}
