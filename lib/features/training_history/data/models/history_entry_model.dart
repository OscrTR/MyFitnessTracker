import '../../domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    super.id,
    required super.trainingId,
    required super.trainingExerciseId,
    super.setNumber,
    super.multisetSetNumber,
    required super.date,
    super.reps,
    super.weight,
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
      multisetSetNumber: json['multiset_set_number'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      reps: json['reps'],
      weight: json['weight'],
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
      'multiset_set_number': multisetSetNumber,
      'date': date.millisecondsSinceEpoch,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'pace': pace,
    };
  }
}
