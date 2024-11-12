import 'package:equatable/equatable.dart';

import 'training_exercise.dart';

class Multiset extends Equatable {
  final int? id;
  final int? trainingId;
  final List<TrainingExercise> trainingExercises;
  final int sets;
  final int setRest;
  final int multisetRest;
  final String specialInstructions;
  final String objectives;
  final int position;

  const Multiset(
      {this.id,
      required this.trainingId,
      required this.trainingExercises,
      required this.sets,
      required this.setRest,
      required this.multisetRest,
      required this.specialInstructions,
      required this.objectives,
      required this.position});

  @override
  List<Object?> get props => [
        id,
        trainingId,
        trainingExercises,
        sets,
        setRest,
        multisetRest,
        specialInstructions,
        objectives,
        position
      ];
}
