import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/muscle_repository.dart';

import '../entities/muscle.dart';

class FetchMuscles extends Usecase<List<Muscle>, void> {
  final MuscleRepository repository;

  FetchMuscles(this.repository);

  @override
  Future<Either<Failure, List<Muscle>>> call(void params) async {
    try {
      return await repository.fetchMuscles();
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}
