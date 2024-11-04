import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/delete_multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/delete_training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/delete_training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/fetch_multisets.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/fetch_training_exercises.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/fetch_trainings.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/get_training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_training_exercise.dart';

class TrainingManagementUsecases {
  final CreateTrainingExercise createTrainingExercise;
  final FetchTrainingExercises fetchTrainingExercises;
  final UpdateTrainingExercise updateTrainingExercise;
  final DeleteTrainingExercise deleteTrainingExercise;

  final CreateMultiset createMultiset;
  final FetchMultisets fetchMultisets;
  final UpdateMultiset updateMultiset;
  final DeleteMultiset deleteMultiset;

  final CreateTraining createTraining;
  final GetTraining getTraining;
  final FetchTrainings fetchTrainings;
  final UpdateTraining updateTraining;
  final DeleteTraining deleteTraining;

  TrainingManagementUsecases({
    required this.createTrainingExercise,
    required this.fetchTrainingExercises,
    required this.updateTrainingExercise,
    required this.deleteTrainingExercise,
    required this.createMultiset,
    required this.fetchMultisets,
    required this.updateMultiset,
    required this.deleteMultiset,
    required this.createTraining,
    required this.getTraining,
    required this.fetchTrainings,
    required this.updateTraining,
    required this.deleteTraining,
  });
}
