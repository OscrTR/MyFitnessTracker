import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

import 'training_exercise.dart';

class Training extends Equatable {
  final String name;
  final String type;
  final bool isSelected;
  final List<TrainingExercise> exercises;
  final List<Multiset> multisets;

  const Training(
      {required this.name,
      required this.type,
      required this.isSelected,
      required this.exercises,
      required this.multisets});

  @override
  List<Object?> get props => [name, type, isSelected, exercises, multisets];
}
