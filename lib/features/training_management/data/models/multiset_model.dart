import '../../domain/entities/multiset.dart';
import 'training_exercise_model.dart';

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
    required super.position,
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
      position: json['position'] as int,
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
      'position': position,
    };
  }

  factory MultisetModel.fromMultisetWithId(Multiset multiset, int trainingId) {
    return MultisetModel(
        id: multiset.id,
        trainingId:
            trainingId, // Ensure this line assigns the passed trainingId
        sets: multiset.sets,
        setRest: multiset.setRest,
        multisetRest: multiset.multisetRest,
        specialInstructions: multiset.specialInstructions,
        objectives: multiset.objectives,
        trainingExercises: multiset.trainingExercises,
        position: multiset.position);
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
        position: multiset.position);
  }
}
