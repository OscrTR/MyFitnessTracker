import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

class MultisetModel extends Multiset {
  const MultisetModel({
    required super.trainingId,
    required super.exercises,
    required super.sets,
    required super.setRest,
    required super.multisetRest,
    required super.specialInstructions,
    required super.objectives,
  });

  factory MultisetModel.fromJson(Map<String, dynamic> json) {
    return MultisetModel(
      trainingId: json['trainingId'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((exerciseJson) => TrainingExerciseModel.fromJson(
              exerciseJson as Map<String, dynamic>))
          .toList(),
      sets: json['sets'] as int,
      setRest: json['setRest'] as int,
      multisetRest: json['multisetRest'] as int,
      specialInstructions: json['specialInstructions'] as String,
      objectives: json['objectives'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainingId': trainingId,
      'exercises': exercises
          .map((exercise) => (exercise as TrainingExerciseModel).toJson())
          .toList(),
      'sets': sets,
      'setRest': setRest,
      'multisetRest': multisetRest,
      'specialInstructions': specialInstructions,
      'objectives': objectives,
    };
  }
}
