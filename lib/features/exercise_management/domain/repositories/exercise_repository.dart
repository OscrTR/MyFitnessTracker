import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/exercise.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, Exercise>> getExercise(int id);

  Future<Either<Failure, List<Exercise>>> fetchExercises();

  Future<Either<Failure, Exercise>> createExercise(Exercise exercise);

  Future<Either<Failure, Exercise>> updateExercise(Exercise exercise);

  Future<Either<Failure, void>> deleteExercise(int id);
}
