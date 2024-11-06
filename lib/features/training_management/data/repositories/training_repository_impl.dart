import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/training_local_data_source.dart';
import '../../domain/entities/training.dart';
import '../../domain/repositories/training_repository.dart';

import '../../../../core/error/exceptions.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final TrainingLocalDataSource localDataSource;

  TrainingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Training>> createTraining(Training training) async {
    try {
      final createdTraining = await localDataSource.createTraining(training);
      return Right(createdTraining);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTraining(int id) async {
    try {
      await localDataSource.deleteTraining(id);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Training>>> fetchTrainings() async {
    try {
      return Right(await localDataSource.fetchTrainings());
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Training>> getTraining(int id) async {
    try {
      return Right(await localDataSource.getTraining(id));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Training>> updateTraining(Training training) async {
    try {
      final updatedTraining = await localDataSource.updateTraining(training);
      return Right(updatedTraining);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
