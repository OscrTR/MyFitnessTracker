import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

import '../../../../core/error/exceptions.dart';
import '../datasources/training_exercise_local_data_source.dart';

class TrainingExerciseRepositoryImpl implements TrainingExerciseRepository {
  final TrainingExerciseLocalDataSource localDataSource;

  TrainingExerciseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, TrainingExercise>> createTrainingExercise(
      TrainingExercise trainingExercise) async {
    try {
      final createdTrainingExercise =
          await localDataSource.createTrainingExercise(trainingExercise);
      return Right(createdTrainingExercise);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrainingExercise(int id) async {
    try {
      await localDataSource.deleteTrainingExercise(id);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<TrainingExercise>>> fetchTrainingExercises(
      int trainingId) async {
    try {
      return Right(await localDataSource.fetchTrainingExercises(trainingId));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, TrainingExercise>> updateTrainingExercise(
      TrainingExercise trainingExercise) async {
    try {
      final updatedTrainingExercise =
          await localDataSource.updateTrainingExercise(trainingExercise);
      return Right(updatedTrainingExercise);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
