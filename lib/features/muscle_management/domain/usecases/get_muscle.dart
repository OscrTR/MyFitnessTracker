import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/muscle_repository.dart';

import '../entities/muscle.dart';

class GetMuscle extends Usecase<Muscle, Params> {
  final MuscleRepository repository;

  GetMuscle(this.repository);

  @override
  Future<Either<Failure, Muscle>> call(Params params) async {
    try {
      return await repository.getMuscle(params.id);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object> get props => [id];
}
