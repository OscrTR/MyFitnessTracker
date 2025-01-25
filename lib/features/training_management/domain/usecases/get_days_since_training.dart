import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/training_repository.dart';

class GetDaysSinceTraining extends Usecase<int?, Params> {
  final TrainingRepository repository;

  GetDaysSinceTraining(this.repository);

  @override
  Future<Either<Failure, int?>> call(Params params) async {
    try {
      return await repository.getDaysSinceTraining(params.id);
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
