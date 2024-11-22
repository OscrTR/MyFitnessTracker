import 'package:equatable/equatable.dart';

import 'training_exercise.dart';

class Multiset extends Equatable {
  final int? id;
  final int? trainingId;
  final List<TrainingExercise>? trainingExercises;
  final int? sets;
  final int? setRest;
  final int? multisetRest;
  final String? specialInstructions;
  final String? objectives;
  final int? position;
  final String? key;

  const Multiset({
    this.id,
    required this.trainingId,
    required this.trainingExercises,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.specialInstructions,
    required this.objectives,
    required this.position,
    this.key,
  });

  Multiset copyWith({
    int? id,
    int? trainingId,
    List<TrainingExercise>? trainingExercises,
    int? sets,
    int? setRest,
    int? multisetRest,
    String? specialInstructions,
    String? objectives,
    int? position,
    String? key,
  }) {
    return Multiset(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      trainingExercises: trainingExercises ?? this.trainingExercises,
      sets: sets ?? this.sets,
      setRest: setRest ?? this.setRest,
      multisetRest: multisetRest ?? this.multisetRest,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
      position: position ?? this.position,
      key: key ?? this.key,
    );
  }

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
