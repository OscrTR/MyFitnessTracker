import '../../domain/entities/training_exercise.dart';

class TrainingExerciseModel extends TrainingExercise {
  const TrainingExerciseModel({
    required super.id,
    required super.trainingId,
    required super.multisetId,
    required super.exerciseId,
    required super.trainingExerciseType,
    required super.specialInstructions,
    required super.objectives,
    required super.runExerciseTarget,
    required super.targetDistance,
    required super.targetDuration,
    required super.isTargetRythmSelected,
    required super.targetRythm,
    required super.intervals,
    required super.isIntervalInDistance,
    required super.intervalDistance,
    required super.intervalDuration,
    required super.intervalRest,
    required super.sets,
    required super.isSetsInReps,
    required super.minReps,
    required super.maxReps,
    required super.actualReps,
    required super.duration,
    required super.setRest,
    required super.exerciseRest,
    required super.manualStart,
    required super.position,
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
      runExerciseTarget:
          RunExerciseTarget.values[json['run_exercise_target'] as int],
      targetDistance: json['target_distance'] as int?,
      targetDuration: json['target_duration'] as int?,
      isTargetRythmSelected:
          (json['is_target_rythm_selected'] as int?) == 1 ? true : false,
      targetRythm: json['target_rythm'] as int?,
      intervals: json['intervals'] as int?,
      isIntervalInDistance:
          (json['is_interval_in_distance'] as int?) == 1 ? true : false,
      intervalDistance: json['interval_distance'] as int?,
      intervalDuration: json['interval_duration'] as int?,
      intervalRest: json['interval_rest'] as int?,
      sets: json['sets'] as int?,
      isSetsInReps: (json['is_sets_in_reps'] as int?) == 1 ? true : false,
      minReps: json['min_reps'] as int?,
      maxReps: json['max_reps'] as int?,
      actualReps: json['actual_reps'] as int?,
      duration: json['duration'] as int?,
      setRest: json['set_rest'] as int?,
      exerciseRest: json['exercise_rest'] as int?,
      manualStart: (json['manual_start'] as int?) == 1 ? true : false,
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'multiset_id': multisetId,
      'exercise_id': exerciseId,
      'training_exercise_type': trainingExerciseType?.index ?? -1,
      'special_instructions': specialInstructions,
      'objectives': objectives,
      'run_exercise_target': runExerciseTarget?.index ?? -1,
      'target_distance': targetDistance,
      'target_duration': targetDuration,
      'is_target_rythm_selected': isTargetRythmSelected == true ? 1 : 0,
      'target_rythm': targetRythm,
      'intervals': intervals,
      'is_interval_in_distance': isIntervalInDistance == true ? 1 : 0,
      'interval_distance': intervalDistance,
      'interval_duration': intervalDuration,
      'interval_rest': intervalRest,
      'sets': sets,
      'is_sets_in_reps': isSetsInReps == true ? 1 : 0,
      'min_reps': minReps,
      'max_reps': maxReps,
      'actual_reps': actualReps,
      'duration': duration,
      'set_rest': setRest,
      'exercise_rest': exerciseRest,
      'manual_start': manualStart == true ? 1 : 0,
      'position': position,
    };
  }

  factory TrainingExerciseModel.fromTrainingExercisewithId(
      TrainingExercise exercise,
      {int? trainingId,
      int? multisetId}) {
    return TrainingExerciseModel(
      id: exercise.id,
      trainingId: trainingId,
      multisetId: multisetId,
      exerciseId: exercise.exerciseId,
      trainingExerciseType: exercise.trainingExerciseType,
      specialInstructions: exercise.specialInstructions,
      objectives: exercise.objectives,
      runExerciseTarget: exercise.runExerciseTarget,
      targetDistance: exercise.targetDistance,
      targetDuration: exercise.targetDuration,
      isTargetRythmSelected: exercise.isTargetRythmSelected,
      targetRythm: exercise.targetRythm,
      intervals: exercise.intervals,
      isIntervalInDistance: exercise.isIntervalInDistance,
      intervalDistance: exercise.intervalDistance,
      intervalDuration: exercise.intervalDuration,
      intervalRest: exercise.intervalRest,
      sets: exercise.sets,
      isSetsInReps: exercise.isSetsInReps,
      minReps: exercise.minReps,
      maxReps: exercise.maxReps,
      actualReps: exercise.actualReps,
      duration: exercise.duration,
      setRest: exercise.setRest,
      exerciseRest: exercise.exerciseRest,
      manualStart: exercise.manualStart,
      position: exercise.position,
    );
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
        runExerciseTarget: exercise.runExerciseTarget,
        targetDistance: exercise.targetDistance,
        targetDuration: exercise.targetDuration,
        isTargetRythmSelected: exercise.isTargetRythmSelected,
        targetRythm: exercise.targetRythm,
        intervals: exercise.intervals,
        isIntervalInDistance: exercise.isIntervalInDistance,
        intervalDistance: exercise.intervalDistance,
        intervalDuration: exercise.intervalDuration,
        intervalRest: exercise.intervalRest,
        sets: exercise.sets,
        isSetsInReps: exercise.isSetsInReps,
        minReps: exercise.minReps,
        maxReps: exercise.maxReps,
        actualReps: exercise.actualReps,
        duration: exercise.duration,
        setRest: exercise.setRest,
        exerciseRest: exercise.exerciseRest,
        manualStart: exercise.manualStart,
        position: exercise.position);
  }
}
