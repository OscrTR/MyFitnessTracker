import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

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
      if (params.name.isEmpty) {
        return const Left(InvalidExerciseNameFailure());
      }

      final exercise = Exercise(
        id: params.id,
        name: params.name,
        description: params.description,
        imagePath: params.imagePath,
      );

      return await repository.updateExercise(exercise);
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
