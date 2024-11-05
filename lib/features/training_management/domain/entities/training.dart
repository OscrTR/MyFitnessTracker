import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

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

  Training copyWith({
    int? id,
    String? name,
    TrainingType? type,
    bool? isSelected,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      trainingExercises: trainingExercises ?? this.trainingExercises,
      multisets: multisets ?? this.multisets,
    );
  }
}
