import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../repositories/training_repository.dart';

class FetchTrainings extends Usecase<List<Training>, void> {
  final TrainingRepository repository;

  FetchTrainings(this.repository);

  @override
  Future<Either<Failure, List<Training>>> call(void params) async {
    try {
      return await repository.fetchTrainings();
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}
