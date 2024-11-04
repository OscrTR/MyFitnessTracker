import 'package:equatable/equatable.dart';

import 'training_exercise.dart';

class Multiset extends Equatable {
  final int? id;
  final int? trainingId;
  final List<TrainingExercise> exercises;
  final int sets;
  final int setRest;
  final int multisetRest;
  final String specialInstructions;
  final String objectives;

  const Multiset({
    this.id,
    required this.trainingId,
    required this.exercises,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.specialInstructions,
    required this.objectives,
  });

  @override
  List<Object?> get props => [
        id,
        trainingId,
        exercises,
        sets,
        setRest,
        multisetRest,
        specialInstructions,
        objectives
      ];
}
