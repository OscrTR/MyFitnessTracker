import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/muscle_repository.dart';

class DeleteMuscle extends Usecase<void, Params> {
  final MuscleRepository repository;

  DeleteMuscle(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    try {
      return await repository.deleteMuscle(params.id);
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
