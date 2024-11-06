import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/training_repository.dart';

class DeleteTraining extends Usecase<void, Params> {
  final TrainingRepository repository;

  DeleteTraining(this.repository);

  @override
  Future<Either<Failure, void>> call(params) async {
    try {
      return await repository.deleteTraining(params.id);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object?> get props => [id];
}
