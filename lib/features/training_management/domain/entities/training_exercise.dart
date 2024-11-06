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
  final int? reps;
  final int? duration;
  final int? setRest;
  final int? exerciseRest;
  final bool? manualStart;

  const TrainingExercise({
    required this.id,
    required this.trainingId,
    required this.multisetId,
    required this.exerciseId,
    required this.trainingExerciseType,
    required this.specialInstructions,
    required this.objectives,
    required this.targetDistance,
    required this.targetDuration,
    required this.targetRythm,
    required this.intervals,
    required this.intervalDistance,
    required this.intervalDuration,
    required this.intervalRest,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.setRest,
    required this.exerciseRest,
    required this.manualStart,
  });

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
        reps,
        duration,
        setRest,
        exerciseRest,
        manualStart,
      ];
}
