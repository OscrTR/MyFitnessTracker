import 'package:equatable/equatable.dart';

class TrainingExercise extends Equatable {
  final int? id;
  final int? trainingId;
  final int? multisetId;
  final int? exerciseId;
  final TrainingExerciseType? trainingExerciseType;
  final String? specialInstructions;
  final String? objectives;
  final RunExerciseTarget? runExerciseTarget;
  final int? targetDistance;
  final int? targetDuration;
  final bool? isTargetPaceSelected;
  final int? targetPace;
  final int? sets;
  final bool? isSetsInReps;
  final int? minReps;
  final int? maxReps;
  final int? duration;
  final int? setRest;
  final int? exerciseRest;
  final bool? autoStart;
  final int? position;
  final int? intensity;
  final String? key;

  const TrainingExercise({
    this.id,
    this.trainingId,
    this.multisetId,
    this.exerciseId,
    this.trainingExerciseType,
    this.specialInstructions,
    this.objectives,
    this.runExerciseTarget,
    this.targetDistance,
    this.targetDuration,
    this.isTargetPaceSelected,
    this.targetPace,
    this.sets,
    this.isSetsInReps,
    this.minReps,
    this.maxReps,
    this.duration,
    this.setRest,
    this.exerciseRest,
    this.autoStart,
    this.position,
    this.intensity,
    this.key,
  });

  TrainingExercise copyWith({
    int? id,
    int? trainingId,
    int? multisetId,
    int? exerciseId,
    TrainingExerciseType? trainingExerciseType,
    String? specialInstructions,
    String? objectives,
    RunExerciseTarget? runExerciseTarget,
    int? targetDistance,
    int? targetDuration,
    bool? isTargetPaceSelected,
    int? targetPace,
    int? sets,
    bool? isSetsInReps,
    int? minReps,
    int? maxReps,
    int? duration,
    int? setRest,
    int? exerciseRest,
    bool? autoStart,
    int? position,
    int? intensity,
    String? key,
  }) {
    return TrainingExercise(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      multisetId: multisetId ?? this.multisetId,
      exerciseId: exerciseId ?? this.exerciseId,
      trainingExerciseType: trainingExerciseType ?? this.trainingExerciseType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
      runExerciseTarget: runExerciseTarget ?? this.runExerciseTarget,
      targetDistance: targetDistance ?? this.targetDistance,
      targetDuration: targetDuration ?? this.targetDuration,
      isTargetPaceSelected: isTargetPaceSelected ?? this.isTargetPaceSelected,
      targetPace: targetPace ?? this.targetPace,
      sets: sets ?? this.sets,
      isSetsInReps: isSetsInReps ?? this.isSetsInReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      duration: duration ?? this.duration,
      setRest: setRest ?? this.setRest,
      exerciseRest: exerciseRest ?? this.exerciseRest,
      autoStart: autoStart ?? this.autoStart,
      position: position ?? this.position,
      intensity: intensity ?? this.intensity,
      key: key ?? this.key,
    );
  }

  TrainingExercise copyWithExerciseIdNull() {
    return TrainingExercise(
      id: id,
      trainingId: trainingId,
      multisetId: multisetId,
      exerciseId: null,
      trainingExerciseType: trainingExerciseType,
      specialInstructions: specialInstructions,
      objectives: objectives,
      runExerciseTarget: runExerciseTarget,
      targetDistance: targetDistance,
      targetDuration: targetDuration,
      isTargetPaceSelected: isTargetPaceSelected,
      targetPace: targetPace,
      sets: sets,
      isSetsInReps: isSetsInReps,
      minReps: minReps,
      maxReps: maxReps,
      duration: duration,
      setRest: setRest,
      exerciseRest: exerciseRest,
      autoStart: autoStart,
      position: position,
      intensity: intensity,
      key: key,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trainingId,
        multisetId,
        exerciseId,
        trainingExerciseType,
        specialInstructions,
        objectives,
        runExerciseTarget,
        targetDistance,
        targetDuration,
        isTargetPaceSelected,
        targetPace,
        sets,
        isSetsInReps,
        minReps,
        maxReps,
        duration,
        setRest,
        exerciseRest,
        autoStart,
        position,
        intensity,
        key,
      ];
}

enum TrainingExerciseType {
  run,
  yoga,
  workout,
  meditation;

  String translate(String locale) {
    switch (this) {
      case TrainingExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';

      case TrainingExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';

      case TrainingExerciseType.run:
        return locale == 'fr' ? 'Course' : 'Run';

      case TrainingExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
    }
  }
}

enum RunExerciseTarget {
  distance,
  duration;

  String translate(String locale) {
    switch (this) {
      case RunExerciseTarget.distance:
        return locale == 'fr' ? 'Distance' : 'Distance';

      case RunExerciseTarget.duration:
        return locale == 'fr' ? 'Durée' : 'Duration';
    }
  }
}
