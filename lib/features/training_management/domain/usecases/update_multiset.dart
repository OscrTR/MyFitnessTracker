import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/usecases/usecase.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_training_exercise.dart';

import '../entities/multiset.dart';
import '../entities/training_exercise.dart.dart';

class UpdateMultiset extends Usecase<Multiset, UpdateMultisetParams> {
  final MultisetRepository repository;
  final UpdateTrainingExercise updateTrainingExercise;

  UpdateMultiset(this.repository, this.updateTrainingExercise);

//TODO que faire pour des exercices qui seraient ajoutés ou supprimés du multiset ?
  @override
  Future<Either<Failure, Multiset>> call(UpdateMultisetParams params) async {
    try {
      // Step 1: Collect all exercises in a list
      final List<TrainingExercise> collectedExercises = [];

      for (var exerciseParams in params.exercises) {
        final exerciseResult = await updateTrainingExercise(exerciseParams);
        exerciseResult.fold(
          (failure) => Left(failure), // Exit early on failure
          (exercise) => collectedExercises.add(exercise),
        );
      }

      // Step 2: Create the Multiset with the complete list of exercises
      final multiset = Multiset(
        id: params.id,
        trainingId: params.trainingId,
        exercises: collectedExercises,
        sets: params.sets,
        setRest: params.setRest,
        multisetRest: params.multisetRest,
        specialInstructions: params.specialInstructions,
        objectives: params.objectives,
      );

      // Step 3: Save the multiset
      final multisetResult = await repository.createMultiset(multiset);
      return multisetResult;
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class UpdateMultisetParams extends Equatable {
  final int? id;
  final int trainingId;
  final List<UpdateTrainingExerciseParams> exercises;
  final int sets;
  final int setRest;
  final int multisetRest;
  final String specialInstructions;
  final String objectives;

  const UpdateMultisetParams(
      {this.id,
      required this.trainingId,
      required this.exercises,
      required this.sets,
      required this.setRest,
      required this.multisetRest,
      required this.specialInstructions,
      required this.objectives});

  @override
  List<Object?> get props => [
        id,
        trainingId,
        exercises,
        sets,
        setRest,
        multisetRest,
        specialInstructions,
        objectives
      ];
}
