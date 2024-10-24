import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class CreateExercise extends Usecase<Exercise, Params> {
  final ExerciseRepository repository;

  CreateExercise(this.repository);

  @override
  Future<Either<Failure, Exercise>> call(Params params) async {
    final exercise = Exercise(
      name: params.name,
      description: params.description,
      imageName: params.imageName,
    );
    return await repository.createExercise(exercise);
  }
}

class Params extends Equatable {
  final String name;
  final String description;
  final String imageName;

  const Params({
    required this.name,
    required this.description,
    required this.imageName,
  });

  @override
  List<Object> get props => [name, description, imageName];
}
