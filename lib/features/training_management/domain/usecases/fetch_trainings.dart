import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';

class FetchTrainings extends Usecase<List<Training>, void> {
  final TrainingRepository repository;

  FetchTrainings(this.repository);

  @override
  Future<Either<Failure, List<Training>>> call(void params) async {
    return await repository.fetchTrainings();
  }
}
