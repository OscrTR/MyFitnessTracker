import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import '../../../training_management/domain/entities/training_exercise.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final int trainingId;
  final TrainingType trainingType;
  final int trainingExerciseId;
  final TrainingExerciseType trainingExerciseType;
  final int setNumber;
  final int? multisetSetNumber;
  final DateTime date;
  final int? reps;
  final int? weight;
  final int? duration;
  final int? distance;
  final int? pace;
  final int? calories;
  final String trainingNameAtTime;
  final String exerciseNameAtTime;
  final int intensity;

  const HistoryEntry({
    this.id,
    required this.trainingId,
    required this.trainingType,
    required this.trainingExerciseId,
    required this.trainingExerciseType,
    required this.setNumber,
    required this.multisetSetNumber,
    required this.date,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.pace,
    this.calories,
    required this.trainingNameAtTime,
    required this.exerciseNameAtTime,
    required this.intensity,
  });

  HistoryEntry copyWith({
    int? reps,
    int? weight,
    int? duration,
    int? distance,
    int? pace,
    int? calories,
    String? trainingNameAtTime,
    String? exerciseNameAtTime,
    int? intensity,
  }) {
    return HistoryEntry(
      id: id,
      trainingId: trainingId,
      trainingType: trainingType,
      trainingExerciseId: trainingExerciseId,
      trainingExerciseType: trainingExerciseType,
      setNumber: setNumber,
      multisetSetNumber: multisetSetNumber,
      date: date,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      calories: calories ?? this.calories,
      trainingNameAtTime: trainingNameAtTime ?? this.trainingNameAtTime,
      exerciseNameAtTime: exerciseNameAtTime ?? this.exerciseNameAtTime,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      trainingId,
      trainingType,
      trainingExerciseId,
      trainingExerciseType,
      setNumber,
      multisetSetNumber,
      date,
      reps,
      weight,
      duration,
      distance,
      pace,
      calories,
      trainingNameAtTime,
      exerciseNameAtTime,
      intensity,
    ];
  }
}
