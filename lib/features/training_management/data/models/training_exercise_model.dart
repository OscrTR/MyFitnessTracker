import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

class TrainingExerciseModel extends TrainingExercise {
  const TrainingExerciseModel({
    required super.id,
    required super.trainingId,
    required super.multisetId,
    required super.exerciseId,
    required super.trainingExerciseType,
    required super.specialInstructions,
    required super.objectives,
    required super.targetDistance,
    required super.targetDuration,
    required super.targetRythm,
    required super.intervals,
    required super.intervalDistance,
    required super.intervalDuration,
    required super.intervalRest,
    required super.sets,
    required super.reps,
    required super.duration,
    required super.setRest,
    required super.exerciseRest,
    required super.manualStart,
  });

  factory TrainingExerciseModel.fromJson(Map<String, dynamic> json) {
    return TrainingExerciseModel(
      id: json['id'] as int?,
      trainingId: json['training_id'] as int?,
      multisetId: json['multiset_id'] as int?,
      exerciseId: json['exercise_id'] as int?,
      trainingExerciseType:
          TrainingExerciseType.values[json['training_exercise_type'] as int],
      specialInstructions: json['special_instructions'] as String?,
      objectives: json['objectives'] as String?,
      targetDistance: json['target_distance'] as int?,
      targetDuration: json['target_duration'] as int?,
      targetRythm: json['target_rythm'] as int?,
      intervals: json['intervals'] as int?,
      intervalDistance: json['interval_distance'] as int?,
      intervalDuration: json['interval_duration'] as int?,
      intervalRest: json['interval_rest'] as int?,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      duration: json['duration'] as int?,
      setRest: json['set_rest'] as int?,
      exerciseRest: json['exercise_rest'] as int?,
      manualStart: (json['manual_start'] as int?) == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'multiset_id': multisetId,
      'exercise_id': exerciseId,
      'training_exercise_type': trainingExerciseType!.index,
      'special_instructions': specialInstructions,
      'objectives': objectives,
      'target_distance': targetDistance,
      'target_duration': targetDuration,
      'target_rythm': targetRythm,
      'intervals': intervals,
      'interval_distance': intervalDistance,
      'interval_duration': intervalDuration,
      'interval_rest': intervalRest,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'set_rest': setRest,
      'exercise_rest': exerciseRest,
      'manual_start': manualStart == true ? 1 : 0,
    };
  }

  factory TrainingExerciseModel.fromTrainingExercise(
      TrainingExercise exercise) {
    return TrainingExerciseModel(
      id: exercise.id,
      trainingId: exercise.trainingId,
      multisetId: exercise.multisetId,
      exerciseId: exercise.exerciseId,
      trainingExerciseType: exercise.trainingExerciseType,
      specialInstructions: exercise.specialInstructions,
      objectives: exercise.objectives,
      targetDistance: exercise.targetDistance,
      targetDuration: exercise.targetDuration,
      targetRythm: exercise.targetRythm,
      intervals: exercise.intervals,
      intervalDistance: exercise.intervalDistance,
      intervalDuration: exercise.intervalDuration,
      intervalRest: exercise.intervalRest,
      sets: exercise.sets,
      reps: exercise.reps,
      duration: exercise.duration,
      setRest: exercise.setRest,
      exerciseRest: exercise.exerciseRest,
      manualStart: exercise.manualStart,
    );
  }
}
