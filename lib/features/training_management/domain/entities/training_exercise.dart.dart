import 'package:equatable/equatable.dart';

abstract class TrainingExercise extends Equatable {
  final int? id;
  final int? trainingId;
  final int? multisetId;
  final String? specialInstructions;
  final String? objectives;

  const TrainingExercise({
    required this.id,
    required this.trainingId,
    required this.multisetId,
    required this.specialInstructions,
    required this.objectives,
  });

  @override
  List<Object?> get props => [
        id,
        trainingId,
        multisetId,
        specialInstructions,
        objectives,
      ];
}
