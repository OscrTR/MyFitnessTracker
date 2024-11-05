import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

class MultisetModel extends Multiset {
  const MultisetModel({
    super.id,
    required super.trainingId,
    required super.trainingExercises,
    required super.sets,
    required super.setRest,
    required super.multisetRest,
    required super.specialInstructions,
    required super.objectives,
  });

  factory MultisetModel.fromJson(Map<String, dynamic> json) {
    return MultisetModel(
      id: json['id'] as int?,
      trainingId: json['training_id'] as int,
      trainingExercises: (json['training_exercises'] as List<dynamic>)
          .map((exerciseJson) => TrainingExerciseModel.fromJson(
              exerciseJson as Map<String, dynamic>))
          .toList(),
      sets: json['sets'] as int,
      setRest: json['set_rest'] as int,
      multisetRest: json['multiset_rest'] as int,
      specialInstructions: json['special_instructions'] as String,
      objectives: json['objectives'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'sets': sets,
      'set_rest': setRest,
      'multiset_rest': multisetRest,
      'special_instructions': specialInstructions,
      'objectives': objectives,
    };
  }

  factory MultisetModel.fromMultiset(Multiset multiset) {
    return MultisetModel(
      id: multiset.id,
      trainingId: multiset.trainingId,
      trainingExercises: multiset.trainingExercises,
      sets: multiset.sets,
      setRest: multiset.setRest,
      multisetRest: multiset.multisetRest,
      specialInstructions: multiset.specialInstructions,
      objectives: multiset.objectives,
    );
  }
}
