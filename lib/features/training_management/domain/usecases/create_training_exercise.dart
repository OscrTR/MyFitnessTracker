import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/run_exercise.dart';

import 'package:my_fitness_tracker/features/training_management/domain/entities/workout_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/yoga_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training_exercise.dart.dart';

class CreateTrainingExercise
    extends Usecase<TrainingExercise, CreateTrainingExerciseParams> {
  final TrainingExerciseRepository repository;

  CreateTrainingExercise(this.repository);

  @override
  Future<Either<Failure, TrainingExercise>> call(
      CreateTrainingExerciseParams params) async {
    try {
      final trainingExercise = createExerciseFromParams(params);

      return await repository.createTrainingExercise(trainingExercise);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  TrainingExercise createExerciseFromParams(
      CreateTrainingExerciseParams params) {
    switch (params.exerciseType) {
      case ExerciseType.run:
        return RunExercise(
          id: null,
          trainingId: params.trainingId,
          multisetId: params.multisetId,
          targetDistance: params.targetDistance,
          targetDuration: params.targetDuration,
          targetRythm: params.targetRythm,
          intervals: params.intervals,
          intervalDistance: params.intervalDistance,
          intervalDuration: params.intervalDuration,
          intervalRest: params.intervalRest,
          specialInstructions: params.specialInstructions,
          objectives: params.objectives,
        );
      case ExerciseType.workout:
        return WorkoutExercise(
          id: null,
          trainingId: params.trainingId,
          multisetId: params.multisetId,
          exerciseId: params.exerciseId,
          sets: params.sets,
          reps: params.reps,
          duration: params.duration,
          setRest: params.setRest,
          exerciseRest: params.exerciseRest,
          manualStart: params.manualStart ?? false,
          specialInstructions: params.specialInstructions,
          objectives: params.objectives,
        );
      case ExerciseType.yoga:
        return YogaExercise(
          id: null,
          trainingId: params.trainingId,
          multisetId: params.multisetId,
          exerciseId: params.exerciseId,
          sets: params.sets,
          reps: params.reps,
          duration: params.duration,
          setRest: params.setRest,
          exerciseRest: params.exerciseRest,
          manualStart: params.manualStart ?? false,
          specialInstructions: params.specialInstructions,
          objectives: params.objectives,
        );
      default:
        throw UnsupportedError(
            "Unsupported exercise type: ${params.exerciseType}");
    }
  }
}

enum ExerciseType { yoga, run, workout }

class CreateTrainingExerciseParams extends Equatable {
  final ExerciseType exerciseType;
  final int trainingId;
  final int? multisetId;
  final String? specialInstructions;
  final String? objectives;

  // Workout / Yoga specific fields
  final int? exerciseId;
  final int? sets;
  final int? reps;
  final int? duration;
  final int? setRest;
  final int? exerciseRest;
  final bool? manualStart;

  // Run-specific fields
  final int? targetDistance;
  final int? targetDuration;
  final int? targetRythm;
  final int? intervals;
  final int? intervalDistance;
  final int? intervalDuration;
  final int? intervalRest;

  const CreateTrainingExerciseParams({
    required this.exerciseType,
    required this.trainingId,
    this.multisetId,
    this.specialInstructions,
    this.objectives,
    this.exerciseId,
    this.sets,
    this.reps,
    this.duration,
    this.setRest,
    this.exerciseRest,
    this.manualStart,
    this.targetDistance,
    this.targetDuration,
    this.targetRythm,
    this.intervals,
    this.intervalDistance,
    this.intervalDuration,
    this.intervalRest,
  });

  @override
  List<Object?> get props => [
        exerciseType,
        trainingId,
        multisetId,
        specialInstructions,
        objectives,
        exerciseId,
        sets,
        reps,
        duration,
        setRest,
        exerciseRest,
        manualStart,
        targetDistance,
        targetDuration,
        targetRythm,
        intervals,
        intervalDistance,
        intervalDuration,
        intervalRest,
      ];
}
