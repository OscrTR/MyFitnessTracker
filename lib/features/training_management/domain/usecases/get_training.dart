import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../repositories/training_repository.dart';

class GetTraining extends Usecase<Training, Params> {
  final TrainingRepository repository;

  GetTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(Params params) async {
    try {
      return await repository.getTraining(params.id);
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
