import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class FetchExercises extends Usecase<List<Exercise>, void> {
  final ExerciseRepository repository;

  FetchExercises(this.repository);

  @override
  Future<Either<Failure, List<Exercise>>> call(void params) async {
    return await repository.fetchExercises();
  }
}
