import 'package:equatable/equatable.dart';

enum TrainingExerciseType { run, yoga, workout }

class TrainingExercise extends Equatable {
  final int? id;
  final int? trainingId;
  final int? multisetId;
  final int? exerciseId;
  final TrainingExerciseType? trainingExerciseType;
  final String? specialInstructions;
  final String? objectives;
  final int? targetDistance;
  final int? targetDuration;
  final int? targetRythm;
  final int? intervals;
  final int? intervalDistance;
  final int? intervalDuration;
  final int? intervalRest;
  final int? sets;
  final bool? isSetsInReps;
  final int? minReps;
  final int? maxReps;
  final int? actualReps;
  final int? duration;
  final int? setRest;
  final int? exerciseRest;
  final bool? manualStart;
  final int? position;

  const TrainingExercise({
    this.id,
    this.trainingId,
    this.multisetId,
    this.exerciseId,
    this.trainingExerciseType,
    this.specialInstructions,
    this.objectives,
    this.targetDistance,
    this.targetDuration,
    this.targetRythm,
    this.intervals,
    this.intervalDistance,
    this.intervalDuration,
    this.intervalRest,
    this.sets,
    this.isSetsInReps,
    this.minReps,
    this.maxReps,
    this.actualReps,
    this.duration,
    this.setRest,
    this.exerciseRest,
    this.manualStart,
    this.position,
  });

  TrainingExercise copyWith({
    int? id,
    int? trainingId,
    int? multisetId,
    int? exerciseId,
    TrainingExerciseType? trainingExerciseType,
    String? specialInstructions,
    String? objectives,
    int? targetDistance,
    int? targetDuration,
    int? targetRythm,
    int? intervals,
    int? intervalDistance,
    int? intervalDuration,
    int? intervalRest,
    int? sets,
    bool? isSetsInReps,
    int? minReps,
    int? maxReps,
    int? actualReps,
    int? duration,
    int? setRest,
    int? exerciseRest,
    bool? manualStart,
    int? position,
  }) {
    return TrainingExercise(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      multisetId: multisetId ?? this.multisetId,
      exerciseId: exerciseId ?? this.exerciseId,
      trainingExerciseType: trainingExerciseType ?? this.trainingExerciseType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
      targetDistance: targetDistance ?? this.targetDistance,
      targetDuration: targetDuration ?? this.targetDuration,
      targetRythm: targetRythm ?? this.targetRythm,
      intervals: intervals ?? this.intervals,
      intervalDistance: intervalDistance ?? this.intervalDistance,
      intervalDuration: intervalDuration ?? this.intervalDuration,
      intervalRest: intervalRest ?? this.intervalRest,
      sets: sets ?? this.sets,
      isSetsInReps: isSetsInReps ?? this.isSetsInReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      actualReps: actualReps ?? this.actualReps,
      duration: duration ?? this.duration,
      setRest: setRest ?? this.setRest,
      exerciseRest: exerciseRest ?? this.exerciseRest,
      manualStart: manualStart ?? this.manualStart,
      position: position ?? this.position,
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
        targetDistance,
        targetDuration,
        targetRythm,
        intervals,
        intervalDistance,
        intervalDuration,
        intervalRest,
        sets,
        isSetsInReps,
        minReps,
        maxReps,
        actualReps,
        duration,
        setRest,
        exerciseRest,
        manualStart,
        position,
      ];
}
