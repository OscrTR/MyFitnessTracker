import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/muscle_repository.dart';

class AssignMuscleToExercise extends Usecase<void, Params> {
  final MuscleRepository repository;

  AssignMuscleToExercise(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    try {
      return await repository.assignMuscleToExercise(
          params.exerciseId, params.muscleId, params.isPrimary);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int exerciseId;
  final int muscleId;
  final bool isPrimary;

  const Params(this.exerciseId, this.muscleId, this.isPrimary);

  @override
  List<Object> get props => [exerciseId, muscleId, isPrimary];
}
