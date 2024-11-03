import 'training_exercise.dart.dart';

class YogaExercise extends TrainingExercise {
  final int? exerciseId;
  final int? sets;
  final int? reps;
  final int? duration;
  final int? setRest;
  final int? exerciseRest;
  final bool manualStart;

  const YogaExercise({
    super.id,
    required super.specialInstructions,
    required super.objectives,
    required super.multisetId,
    required super.trainingId,
    required this.exerciseId,
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
        sets,
        reps,
        duration,
        setRest,
        exerciseRest,
        manualStart,
        specialInstructions,
        objectives,
      ];
}
