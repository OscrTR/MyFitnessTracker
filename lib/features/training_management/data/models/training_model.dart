import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

class TrainingModel extends Training {
  const TrainingModel({
    super.id,
    required super.name,
    required super.type,
    required super.isSelected,
    required super.trainingExercises,
    required super.multisets,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: TrainingType.values[json['type'] as int],
      isSelected: (json['is_selected'] as int) == 1 ? true : false,
      trainingExercises: (json['training_exercises'] as List<dynamic>?)
              ?.map((exerciseJson) => TrainingExerciseModel.fromJson(
                  exerciseJson as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
      multisets: (json['multisets'] as List<dynamic>?)
              ?.map((multisetJson) =>
                  MultisetModel.fromJson(multisetJson as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'is_selected': isSelected == true ? 1 : 0,
    };
  }

  factory TrainingModel.fromTraining(Training training) {
    return TrainingModel(
        id: training.id,
        name: training.name,
        type: training.type,
        isSelected: training.isSelected,
        trainingExercises: training.trainingExercises,
        multisets: training.multisets);
  }
}
