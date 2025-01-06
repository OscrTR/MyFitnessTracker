import 'package:my_fitness_tracker/features/training_history/domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    super.id,
    required super.trainingId,
    required super.trainingExerciseId,
    super.setNumber,
    required super.date,
    super.reps,
    super.duration,
    super.distance,
    super.pace,
  });

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id: json['id'],
      trainingId: json['training_id'],
      trainingExerciseId: json['training_exercise_id'],
      setNumber: json['set_number'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      reps: json['reps'],
      duration: json['duration'],
      distance: json['distance'],
      pace: json['pace'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'training_exercise_id': trainingExerciseId,
      'set_number': setNumber,
      'date': date.millisecondsSinceEpoch,
      'reps': reps,
      'duration': duration,
      'distance': distance,
      'pace': pace,
    };
  }
}
