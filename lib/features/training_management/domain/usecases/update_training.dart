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
      if (params.name.isEmpty) {
        return const Left(InvalidExerciseNameFailure());
      }

      final training = Training(
          name: name,
          type: type,
          isSelected: isSelected,
          exercises: exercises,
          multisets: multisets);

      return await repository.updateTraining(training);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;
  final String name;
  final String description;
  final String imagePath;

  const Params({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object> get props => [id, name, description, imagePath];
}
