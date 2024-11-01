import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise_base.dart.dart';

class TrainingExercise extends Equatable {
  final TrainingExerciseBase exercise;

  const TrainingExercise({required this.exercise});

  @override
  List<Object?> get props => [exercise];
}
