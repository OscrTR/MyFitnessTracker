import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

class TrainingModel extends Training {
  const TrainingModel({
    required super.name,
    required super.type,
    required super.isSelected,
    required super.exercises,
    required super.multisets,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      name: json['name'] as String,
      type: json['type'] as TrainingType,
      isSelected: json['isSelected'] as bool,
      exercises: (json['exercises'] as List<dynamic>)
          .map((exerciseJson) => TrainingExerciseModel.fromJson(
              exerciseJson as Map<String, dynamic>))
          .toList(),
      multisets: (json['multisets'] as List<dynamic>)
          .map((multisetJson) =>
              MultisetModel.fromJson(multisetJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'isSelected': isSelected,
      'exercises': exercises
          .map((exercise) => (exercise as TrainingExerciseModel).toJson())
          .toList(),
      'multisets': multisets
          .map((multiset) => (multiset as MultisetModel).toJson())
          .toList(),
    };
  }
}
