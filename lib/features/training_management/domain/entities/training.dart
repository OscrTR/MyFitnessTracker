import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

import 'training_exercise.dart';

enum TrainingType { yoga, workout, run }

class Training extends Equatable {
  final int? id;
  final String name;
  final TrainingType type;
  final bool isSelected;
  final List<TrainingExercise> exercises;
  final List<Multiset> multisets;

  const Training({
    this.id,
    required this.name,
    required this.type,
    required this.isSelected,
    required this.exercises,
    required this.multisets,
  });

  @override
  List<Object?> get props => [id, name, type, isSelected, exercises, multisets];
}
