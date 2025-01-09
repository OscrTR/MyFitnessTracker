import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/muscle_repository.dart';

import '../entities/muscle.dart';

class UpdateMuscle extends Usecase<Muscle, Params> {
  final MuscleRepository repository;

  UpdateMuscle(this.repository);

  @override
  Future<Either<Failure, Muscle>> call(Params params) async {
    try {
      return await repository.updateMuscle(params.muscle);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final Muscle muscle;

  const Params(this.muscle);

  @override
  List<Object> get props => [muscle];
}
