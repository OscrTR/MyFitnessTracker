import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class UpdateExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  UpdateExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    try {
      // Construct the Exercise entity
      final exercise = Exercise(
        id: params.id,
        name: params.name,
        description: params.description,
        imagePath: params.imagePath,
      );

      // Call the repository to save the exercise
      return await repository.updateExercise(exercise);
    } catch (e) {
      // If there is a validation error, return an InvalidExerciseNameFailure
      if (e is ExerciseNameException) {
        return const Left(InvalidExerciseNameFailure());
      }

      // Otherwise, return a generic failure
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
