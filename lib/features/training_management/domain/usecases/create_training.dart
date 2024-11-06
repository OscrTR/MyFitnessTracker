import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/training.dart';
import '../repositories/training_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class CreateTraining extends Usecase<Training, Params> {
  final TrainingRepository repository;

  CreateTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(Params params) async {
    try {
      return await repository.createTraining(params.training);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final Training training;

  const Params(this.training);

  @override
  List<Object?> get props => [training];
}
