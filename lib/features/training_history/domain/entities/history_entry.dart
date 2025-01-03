import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final DateTime date;
  final int? reps;
  final int? duration;
  final int? distance;
  final int? pace;

  const HistoryEntry({
    this.id,
    required this.date,
    this.reps,
    this.duration,
    this.distance,
    this.pace,
  });

  HistoryEntry copyWith({
    int? reps,
    int? duration,
    int? distance,
    int? pace,
  }) {
    return HistoryEntry(
      id: id,
      date: date,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
    );
  }

  @override
  List<Object?> get props => [id, date, reps, duration, distance, pace];
}
