import 'package:equatable/equatable.dart';

import 'multiset.dart';
import 'training_exercise.dart';

enum TrainingType { run, yoga, workout }

class Training extends Equatable {
  final int? id;
  final String name;
  final TrainingType type;
  final bool isSelected;
  final List<TrainingExercise> trainingExercises;
  final List<Multiset> multisets;

  const Training({
    this.id,
    required this.name,
    required this.type,
    required this.isSelected,
    required this.trainingExercises,
    required this.multisets,
  });

  @override
  List<Object?> get props =>
      [id, name, type, isSelected, trainingExercises, multisets];
}
