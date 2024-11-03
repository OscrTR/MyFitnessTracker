import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/multiset.dart';
import '../entities/training_exercise.dart.dart';
import 'create_multiset.dart';
import 'create_training_exercise.dart';

class CreateTraining extends Usecase<Training, CreateTrainingParams> {
  final TrainingRepository repository;
  final CreateMultiset createMultiset;
  final CreateTrainingExercise createTrainingExercise;

  CreateTraining(
      this.repository, this.createMultiset, this.createTrainingExercise);

  @override
  Future<Either<Failure, Training>> call(CreateTrainingParams params) async {
    try {
      // Step 1: Collect all the multisets & exercises
      final List<Multiset> collectedMultisets = [];
      for (var multisetParams in params.multisets) {
        final multisetResult = await createMultiset(multisetParams);
        multisetResult.fold(
          (failure) => Left(failure), // Exit early on failure
          (multiset) => collectedMultisets.add(multiset),
        );
      }

      final List<TrainingExercise> collectedExercises = [];
      for (var exerciseParams in params.exercises) {
        final exerciseResult = await createTrainingExercise(exerciseParams);
        exerciseResult.fold(
          (failure) => Left(failure), // Exit early on failure
          (exercise) => collectedExercises.add(exercise),
        );
      }

      // Step 2: Create the Training with the complete list of multisets and exercises
      final training = Training(
        name: params.name,
        type: params.type,
        isSelected: params.isSelected,
        exercises: collectedExercises,
        multisets: collectedMultisets,
      );
      // Step 3: Save the training
      final trainingResult = await repository.createTraining(training);
      return trainingResult;
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class CreateTrainingParams extends Equatable {
  final String name;
  final TrainingType type;
  final bool isSelected;
  final List<CreateMultisetParams> multisets;
  final List<CreateTrainingExerciseParams> exercises;

  const CreateTrainingParams({
    required this.name,
    required this.type,
    required this.isSelected,
    required this.multisets,
    required this.exercises,
  });

  @override
  List<Object?> get props => [
        name,
        type,
        isSelected,
        multisets,
        exercises,
      ];
}
