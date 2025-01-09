import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/muscle.dart';
import '../../domain/repositories/muscle_repository.dart';
import '../datasources/muscle_local_data_source.dart';

class MuscleRepositoryImpl implements MuscleRepository {
  final MuscleLocalDataSource localDataSource;

  MuscleRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> assignMuscleToExercise(
      int exerciseId, int muscleId, bool isPrimary) async {
    try {
      return Right(await localDataSource.assignMuscleToExercise(
          exerciseId, muscleId, isPrimary));
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Muscle>> createMuscle(Muscle muscle) async {
    try {
      return Right(await localDataSource.createMuscle(muscle));
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMuscle(int id) async {
    try {
      await localDataSource.deleteMuscle(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Muscle>>> fetchMuscles() async {
    try {
      return Right(await localDataSource.fetchMuscles());
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Muscle>> getMuscle(int id) async {
    try {
      return Right(await localDataSource.getMuscle(id));
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Muscle>> updateMuscle(Muscle muscle) async {
    try {
      return Right(await localDataSource.updateMuscle(muscle));
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}
