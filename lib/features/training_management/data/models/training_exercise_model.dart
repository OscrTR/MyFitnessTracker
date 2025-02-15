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
    required super.isTargetPaceSelected,
    required super.targetPace,
    required super.sets,
    required super.isSetsInReps,
    required super.minReps,
    required super.maxReps,
    required super.duration,
    required super.setRest,
    required super.exerciseRest,
    required super.autoStart,
    required super.position,
    required super.intensity,
    required super.key,
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
      isTargetPaceSelected:
          (json['is_target_pace_selected'] as int?) == 1 ? true : false,
      targetPace: json['target_pace'] as int?,
      sets: json['sets'] as int,
      isSetsInReps: (json['is_sets_in_reps'] as int) == 1 ? true : false,
      minReps: json['min_reps'] as int?,
      maxReps: json['max_reps'] as int?,
      duration: json['duration'] as int?,
      setRest: json['set_rest'] as int?,
      exerciseRest: json['exercise_rest'] as int?,
      autoStart: (json['auto_start'] as int) == 0 ? false : true,
      position: json['position'] as int?,
      intensity: json['intensity'] as int,
      key: json['key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'multiset_id': multisetId,
      'exercise_id': exerciseId,
      'training_exercise_type': trainingExerciseType.index,
      'special_instructions': specialInstructions,
      'objectives': objectives,
      'run_exercise_target': runExerciseTarget?.index ?? -1,
      'target_distance': targetDistance,
      'target_duration': targetDuration,
      'is_target_pace_selected': isTargetPaceSelected == true ? 1 : 0,
      'target_pace': targetPace,
      'sets': sets,
      'is_sets_in_reps': isSetsInReps == true ? 1 : 0,
      'min_reps': minReps,
      'max_reps': maxReps,
      'duration': duration,
      'set_rest': setRest,
      'exercise_rest': exerciseRest,
      'auto_start': autoStart == true ? 1 : 0,
      'position': position,
      'intensity': intensity,
      'key': key,
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
      isTargetPaceSelected: exercise.isTargetPaceSelected,
      targetPace: exercise.targetPace,
      sets: exercise.sets,
      isSetsInReps: exercise.isSetsInReps,
      minReps: exercise.minReps,
      maxReps: exercise.maxReps,
      duration: exercise.duration,
      setRest: exercise.setRest,
      exerciseRest: exercise.exerciseRest,
      autoStart: exercise.autoStart,
      position: exercise.position,
      intensity: exercise.intensity,
      key: exercise.key,
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
      isTargetPaceSelected: exercise.isTargetPaceSelected,
      targetPace: exercise.targetPace,
      sets: exercise.sets,
      isSetsInReps: exercise.isSetsInReps,
      minReps: exercise.minReps,
      maxReps: exercise.maxReps,
      duration: exercise.duration,
      setRest: exercise.setRest,
      exerciseRest: exercise.exerciseRest,
      autoStart: exercise.autoStart,
      position: exercise.position,
      intensity: exercise.intensity,
      key: exercise.key,
    );
  }
}
