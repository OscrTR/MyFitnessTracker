import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/run_exercise.dart';
import '../entities/workout_exercise.dart';
import '../entities/yoga_exercise.dart';
import '../repositories/training_exercise_repository.dart';

class UpdateTrainingExercise
    extends Usecase<TrainingExercise, UpdateTrainingExerciseParams> {
  final TrainingExerciseRepository repository;

  UpdateTrainingExercise(this.repository);

  @override
  Future<Either<Failure, TrainingExercise>> call(
      UpdateTrainingExerciseParams params) async {
    try {
      final trainingExercise = updateExerciseFromParams(params);

      return await repository.updateTrainingExercise(trainingExercise);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  TrainingExercise updateExerciseFromParams(
      UpdateTrainingExerciseParams params) {
    switch (params.exerciseType) {
      case ExerciseType.run:
        return RunExercise(
          id: params.id,
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
          id: params.id,
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
          id: params.id,
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

class UpdateTrainingExerciseParams extends Equatable {
  final int id;
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

  const UpdateTrainingExerciseParams({
    required this.id,
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
        id,
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
