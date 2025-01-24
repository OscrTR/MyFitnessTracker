import 'dart:convert';

import '../../domain/entities/training.dart';
import 'multiset_model.dart';
import 'training_exercise_model.dart';

class TrainingModel extends Training {
  const TrainingModel({
    super.id,
    required super.name,
    required super.type,
    required super.trainingExercises,
    required super.multisets,
    super.objectives,
    super.trainingDays,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: TrainingType.values[json['type'] as int],
      trainingExercises: (json['training_exercises'] as List<dynamic>?)
              ?.map((exerciseJson) => TrainingExerciseModel.fromJson(
                  exerciseJson as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
      multisets: (json['multisets'] as List<dynamic>?)
              ?.map((multisetJson) =>
                  MultisetModel.fromJson(multisetJson as Map<String, dynamic>))
              .toList() ??
          [],
      objectives: json['objectives'] as String?,
      trainingDays: parseTrainingDays(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'training_days': json.encode(trainingDays?.map((e) => e.index).toList()),
      'objectives': objectives,
    };
  }

  factory TrainingModel.fromTrainingWithId(Training training, int trainingId) {
    return TrainingModel(
      id: trainingId,
      name: training.name,
      type: training.type,
      multisets: training.multisets,
      objectives: training.objectives,
      trainingExercises: training.trainingExercises,
      trainingDays: training.trainingDays,
    );
  }

  factory TrainingModel.fromTraining(Training training) {
    return TrainingModel(
      id: training.id,
      name: training.name,
      type: training.type,
      trainingExercises: training.trainingExercises,
      objectives: training.objectives,
      multisets: training.multisets,
      trainingDays: training.trainingDays,
    );
  }
}

List<WeekDay> parseTrainingDays(Map<String, dynamic> json) {
  try {
    // Vérification si la clé existe et n'est pas null
    if (!json.containsKey('training_days') || json['training_days'] == null) {
      return [];
    }

    // Décodage du JSON
    final dynamic decodedDays = jsonDecode(json['training_days']);

    // Vérification si le résultat est bien une Liste
    if (decodedDays is! List) {
      return [];
    }

    // Conversion et validation des indices
    return decodedDays
        .whereType<int>() // Filtre uniquement les entiers
        .where((i) =>
            i >= 0 &&
            i < WeekDay.values.length) // Vérifie que l'index est valide
        .map((i) => WeekDay.values[i])
        .toList();
  } catch (e) {
    // En cas d'erreur de parsing JSON ou autre
    print('Erreur lors du parsing des training days: $e');
    return [];
  }
}
