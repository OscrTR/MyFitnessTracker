import 'package:my_fitness_tracker/features/training_history/domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    super.id,
    required super.date,
    super.reps,
    super.duration,
    super.distance,
    super.pace,
  });

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id: json['id'],
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
      'date': date.millisecondsSinceEpoch,
      'reps': reps,
      'duration': duration,
      'distance': distance,
      'pace': pace,
    };
  }
}
