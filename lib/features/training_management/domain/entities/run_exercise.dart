import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise_base.dart.dart';

class RunExercise extends TrainingExerciseBase {
  final int targetDistance;
  final int targetDuration;
  final int targetRythm;
  final int intervals;
  final int intervalDistance;
  final int intervalDuration;
  final int intervalRest;

  const RunExercise({
    required this.targetDistance,
    required this.targetDuration,
    required this.intervals,
    required this.intervalDistance,
    required this.intervalDuration,
    required this.intervalRest,
    required this.targetRythm,
    required super.specialInstructions,
    required super.objectives,
  });

  @override
  List<Object?> get props =>
      super.props +
      [
        targetDistance,
        targetDuration,
        targetRythm,
        intervals,
        intervalDistance,
        intervalDuration,
        intervalRest,
      ];
}
