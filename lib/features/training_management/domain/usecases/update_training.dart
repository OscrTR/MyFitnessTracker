import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../repositories/training_repository.dart';

class UpdateTraining extends Usecase<Training, Params> {
  final TrainingRepository repository;

  UpdateTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(Params params) async {
    try {
      if (params.training.name.isEmpty) {
        return const Left(InvalidNameFailure());
      }

      return await repository.updateTraining(params.training);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final Training training;

  const Params(this.training);

  @override
  List<Object> get props => [training];
}
