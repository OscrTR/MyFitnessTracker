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
      trainingId: json['trainingId'] as int?,
      multisetId: json['multisetId'] as int?,
      exerciseId: json['exerciseId'] as int?,
      trainingExerciseType:
          json['trainingExerciseType'] as TrainingExerciseType,
      specialInstructions: json['specialInstructions'] as String?,
      objectives: json['objectives'] as String?,
      targetDistance: json['targetDistance'] as int?,
      targetDuration: json['targetDuration'] as int?,
      targetRythm: json['targetRythm'] as int?,
      intervals: json['intervals'] as int?,
      intervalDistance: json['intervalDistance'] as int?,
      intervalDuration: json['intervalDuration'] as int?,
      intervalRest: json['intervalRest'] as int?,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      duration: json['duration'] as int?,
      setRest: json['setRest'] as int?,
      exerciseRest: json['exerciseRest'] as int?,
      manualStart: json['manualStart'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingId': trainingId,
      'multisetId': multisetId,
      'exerciseId': exerciseId,
      'trainingExerciseType': trainingExerciseType,
      'specialInstructions': specialInstructions,
      'objectives': objectives,
      'targetDistance': targetDistance,
      'targetDuration': targetDuration,
      'targetRythm': targetRythm,
      'intervals': intervals,
      'intervalDistance': intervalDistance,
      'intervalDuration': intervalDuration,
      'intervalRest': intervalRest,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'setRest': setRest,
      'exerciseRest': exerciseRest,
      'manualStart': manualStart,
    };
  }
}
