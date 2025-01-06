import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final int? trainingId;
  final int? trainingExerciseId;
  final int? setNumber;
  final DateTime date;
  final int? reps;
  final int? duration;
  final int? distance;
  final int? pace;

  const HistoryEntry({
    this.id,
    this.trainingId,
    this.trainingExerciseId,
    this.setNumber,
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
      trainingId: trainingId,
      trainingExerciseId: trainingExerciseId,
      setNumber: setNumber,
      date: date,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trainingId,
        trainingExerciseId,
        setNumber,
        date,
        reps,
        duration,
        distance,
        pace
      ];
}
