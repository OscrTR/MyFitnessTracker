import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart.dart';

class RunExercise extends TrainingExercise {
  final int? targetDistance;
  final int? targetDuration;
  final int? targetRythm;
  final int? intervals;
  final int? intervalDistance;
  final int? intervalDuration;
  final int? intervalRest;

  const RunExercise({
    super.id,
    required super.trainingId,
    required super.multisetId,
    required super.specialInstructions,
    required super.objectives,
    required this.targetDistance,
    required this.targetDuration,
    required this.targetRythm,
    required this.intervals,
    required this.intervalDistance,
    required this.intervalDuration,
    required this.intervalRest,
  });

  @override
  List<Object?> get props =>
      super.props +
      [
        id,
        trainingId,
        multisetId,
        specialInstructions,
        objectives,
        targetDistance,
        targetDuration,
        targetRythm,
        intervals,
        intervalDistance,
        intervalDuration,
        intervalRest,
      ];
}
