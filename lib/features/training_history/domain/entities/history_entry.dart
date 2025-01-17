import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final int? trainingId;
  final int? trainingExerciseId;
  final int? setNumber;
  final int? multisetSetNumber;
  final DateTime date;
  final int? reps;
  final int? weight;
  final int? duration;
  final int? distance;
  final int? pace;

  const HistoryEntry({
    this.id,
    this.trainingId,
    this.trainingExerciseId,
    this.setNumber,
    this.multisetSetNumber,
    required this.date,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.pace,
  });

  HistoryEntry copyWith({
    int? reps,
    int? weight,
    int? duration,
    int? distance,
    int? pace,
  }) {
    return HistoryEntry(
      id: id,
      trainingId: trainingId,
      trainingExerciseId: trainingExerciseId,
      setNumber: setNumber,
      multisetSetNumber: multisetSetNumber,
      date: date,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
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
        multisetSetNumber,
        date,
        reps,
        weight,
        duration,
        distance,
        pace
      ];
}
