import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

import '../../../training_management/domain/entities/training_exercise.dart';
import '../../domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    super.id,
    required super.trainingId,
    required super.trainingType,
    required super.trainingExerciseId,
    required super.trainingExerciseType,
    super.setNumber,
    super.multisetSetNumber,
    required super.date,
    super.reps,
    super.weight,
    super.duration,
    super.distance,
    super.pace,
    super.calories,
    required super.trainingNameAtTime,
    required super.exerciseNameAtTime,
    required super.intensity,
  });

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id: json['id'],
      trainingId: json['training_id'],
      trainingType: TrainingType.values
          .firstWhere((el) => el.name == (json['training_type'] as String)),
      trainingExerciseId: json['training_exercise_id'],
      trainingExerciseType: TrainingExerciseType.values.firstWhere(
          (el) => el.name == (json['training_exercise_type'] as String)),
      setNumber: json['set_number'],
      multisetSetNumber: json['multiset_set_number'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      reps: json['reps'],
      weight: json['weight'],
      duration: json['duration'],
      distance: json['distance'],
      pace: json['pace'],
      calories: json['calories'],
      trainingNameAtTime: json['training_name_at_time'] as String,
      exerciseNameAtTime: json['exercise_name_at_time'] as String,
      intensity: json['intensity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'training_type': trainingType.name,
      'training_exercise_id': trainingExerciseId,
      'training_exercise_type': trainingExerciseType.name,
      'set_number': setNumber,
      'multiset_set_number': multisetSetNumber,
      'date': date.millisecondsSinceEpoch,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'pace': pace,
      'calories': calories,
      'training_name_at_time': trainingNameAtTime,
      'exercise_name_at_time': exerciseNameAtTime,
      'intensity': intensity,
    };
  }
}
