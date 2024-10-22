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
  Future<Either<Failure, Exercise>> createExercise(Exercise exerciseToCreate) {
    // TODO: implement createExercise
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Exercise>> deleteExercise(Exercise exerciseToDelete) {
    // TODO: implement deleteExercise
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Exercise>>> fetchExercises() {
    // TODO: implement fetchExercises
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Exercise>> getExercise(int id) async {
    try {
      return Right(await localDataSource.getExercise(id));
    } on DatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Exercise>> updateExercise(Exercise exerciseToUpdate) {
    // TODO: implement updateExercise
    throw UnimplementedError();
  }
}
