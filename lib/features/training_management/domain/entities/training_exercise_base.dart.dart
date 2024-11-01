import 'package:equatable/equatable.dart';

abstract class TrainingExerciseBase extends Equatable {
  final String specialInstructions;
  final String objectives;

  const TrainingExerciseBase(
      {required this.specialInstructions, required this.objectives});

  @override
  List<Object?> get props => [
        specialInstructions,
        objectives,
      ];
}
