import '../../../exercise_management/domain/entities/exercise.dart';
import 'training_exercise_base.dart.dart';

class WorkoutExercise extends TrainingExerciseBase {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int duration;
  final int setRest;
  final int exerciseRest;
  final bool manualStart;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.setRest,
    required this.exerciseRest,
    required this.manualStart,
    required super.specialInstructions,
    required super.objectives,
  });

  @override
  List<Object?> get props =>
      super.props +
      [
        exercise,
        sets,
        reps,
        duration,
        setRest,
        exerciseRest,
        manualStart,
      ];
}
