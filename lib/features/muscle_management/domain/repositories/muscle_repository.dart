import 'package:dartz/dartz.dart';
import '../entities/muscle.dart';

import '../../../../core/error/failures.dart';

abstract class MuscleRepository {
  Future<Either<Failure, Muscle>> getMuscle(int id);

  Future<Either<Failure, List<Muscle>>> fetchMuscles();

  Future<Either<Failure, Muscle>> createMuscle(Muscle muscle);

  Future<Either<Failure, Muscle>> updateMuscle(Muscle muscle);

  Future<Either<Failure, void>> deleteMuscle(int id);

  Future<Either<Failure, void>> assignMuscleToExercise(
      int exerciseId, int muscleId, bool isPrimary);
}
