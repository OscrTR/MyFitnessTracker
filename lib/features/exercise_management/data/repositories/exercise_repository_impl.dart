import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/exercise_local_data_source.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDataSource localDataSource;

  ExerciseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Exercise>> createExercise(
      Exercise exerciseToCreate) async {
    try {
      final createdExercise =
          await localDataSource.createExercise(exerciseToCreate);
      return Right(createdExercise);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Exercise>> getExercise(int id) async {
    try {
      return Right(await localDataSource.getExercise(id));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Exercise>>> fetchExercises() async {
    try {
      return Right(await localDataSource.fetchExercises());
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Exercise>> updateExercise(
      Exercise exerciseToUpdate) async {
    try {
      final updatedExercise =
          await localDataSource.updateExercise(exerciseToUpdate);
      return Right(updatedExercise);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteExercise(int id) async {
    try {
      await localDataSource.deleteExercise(id);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
