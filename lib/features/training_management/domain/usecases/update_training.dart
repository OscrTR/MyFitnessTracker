import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class UpdateTraining extends Usecase<Training, Params> {
  final TrainingRepository repository;

  UpdateTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(Params params) async {
    try {
      if (params.training.name.isEmpty) {
        return const Left(InvalidExerciseNameFailure());
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
