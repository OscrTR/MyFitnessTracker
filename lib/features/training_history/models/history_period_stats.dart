// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_history/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/helper_functions.dart';

import '../../../core/enums/enums.dart';
import '../../../injection_container.dart';
import 'history_training.dart';

class PeriodStats extends Equatable {
  // Statistiques générales
  final int totalDuration;
  final int totalCalories;
  final int totalTrainingsCount;
  final int runTrainingsCount;
  final int workoutTrainingsCount;
  final int yogaTrainingsCount;

  // Statistiques pour la course
  final int runTotalDistance;
  final int runTotalDrop;

  /// Minutes per km
  final double runAveragePace;
  final int runTotalDuration;

  // Statistiques pour le workout
  final int workoutTotalLoad;
  final int workoutTotalSets;
  final int workoutTotalRest;
  final int workoutTotalDuration;

  // Statistiques pour le yoga
  final int yogaTotalDuration;
  final int yogaUniqueExercises;
  final int yogaTotalMeditationDuration;

  const PeriodStats({
    required this.totalDuration,
    required this.totalCalories,
    required this.totalTrainingsCount,
    required this.runTrainingsCount,
    required this.workoutTrainingsCount,
    required this.yogaTrainingsCount,
    required this.runTotalDistance,
    required this.runTotalDrop,
    required this.runAveragePace,
    required this.runTotalDuration,
    required this.workoutTotalLoad,
    required this.workoutTotalSets,
    required this.workoutTotalRest,
    required this.workoutTotalDuration,
    required this.yogaTotalDuration,
    required this.yogaUniqueExercises,
    required this.yogaTotalMeditationDuration,
  });

  factory PeriodStats.fromTrainings(List<HistoryTraining> trainings) {
    // Filtrer les entraînements par type
    final runTrainings = trainings
        .where((t) => t.training.trainingType == TrainingType.running)
        .toList();
    final workoutTrainings = trainings
        .where((t) => t.training.trainingType == TrainingType.workout)
        .toList();
    final yogaTrainings = trainings
        .where((t) => t.training.trainingType == TrainingType.yoga)
        .toList();

    // Calculer les nombres d'entraînements
    final totalTrainingsCount = trainings.length;
    final runTrainingsCount = runTrainings.length;
    final workoutTrainingsCount = workoutTrainings.length;
    final yogaTrainingsCount = yogaTrainings.length;

    // Calculer les statistiques de course
    final runTotalDistance =
        runTrainings.fold<int>(0, (sum, t) => sum + t.distance);
    final runTotalDrop =
        runTrainings.fold<int>(0, (sum, t) => sum + t.elevation);
    final runTotalDuration =
        runTrainings.fold<int>(0, (sum, t) => sum + t.duration);

    // Calculer l'allure moyenne pondérée par la distance
    double runAveragePace =
        calculateAverage(runTrainings.map((t) => t.pace).toList());

    // Calculer les statistiques de workout
    final workoutTotalLoad =
        workoutTrainings.fold<int>(0, (sum, t) => sum + t.load);
    final workoutTotalSets =
        workoutTrainings.fold<int>(0, (sum, t) => sum + t.sets);
    final workoutTotalRest =
        workoutTrainings.fold<int>(0, (sum, t) => sum + t.rest);
    final workoutTotalDuration =
        workoutTrainings.fold<int>(0, (sum, t) => sum + t.duration);

    // Calculer les statistiques de yoga
    final yogaTotalDuration =
        yogaTrainings.fold<int>(0, (sum, t) => sum + t.duration);
    final yogaTotalMeditationDuration =
        yogaTrainings.fold<int>(0, (sum, t) => sum + t.meditationDuration);

    final int yogaUniqueExercises = yogaTrainings
        .map((t) => t.training.exercises)
        .expand((e) => e)
        .where((exercise) => exercise.exerciseType == ExerciseType.yoga)
        .map((exercise) => exercise.id)
        .toSet()
        .length;

    return PeriodStats(
      totalDuration: trainings.fold<int>(0, (sum, t) => sum + t.duration),
      totalCalories: trainings.fold<int>(0, (sum, t) => sum + t.calories),
      totalTrainingsCount: totalTrainingsCount,
      runTrainingsCount: runTrainingsCount,
      workoutTrainingsCount: workoutTrainingsCount,
      yogaTrainingsCount: yogaTrainingsCount,
      runTotalDistance: runTotalDistance,
      runTotalDrop: runTotalDrop,
      runAveragePace: runAveragePace,
      runTotalDuration: runTotalDuration,
      workoutTotalLoad: workoutTotalLoad,
      workoutTotalSets: workoutTotalSets,
      workoutTotalRest: workoutTotalRest,
      workoutTotalDuration: workoutTotalDuration,
      yogaTotalDuration: yogaTotalDuration,
      yogaUniqueExercises: yogaUniqueExercises,
      yogaTotalMeditationDuration: yogaTotalMeditationDuration,
    );
  }

  @override
  List<Object> get props {
    return [
      totalDuration,
      totalCalories,
      totalTrainingsCount,
      runTrainingsCount,
      workoutTrainingsCount,
      yogaTrainingsCount,
      runTotalDistance,
      runTotalDrop,
      runAveragePace,
      runTotalDuration,
      workoutTotalLoad,
      workoutTotalSets,
      workoutTotalRest,
      workoutTotalDuration,
      yogaTotalDuration,
      yogaUniqueExercises,
      yogaTotalMeditationDuration,
    ];
  }

  // Méthodes de filtrage avec statistiques
  static void getCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    sl<TrainingHistoryBloc>()
        .add(SetNewDateHistoryDateEvent(startDate: startDate, endDate: now));
  }

  static void getCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startDate =
        DateTime(startOfMonth.year, startOfMonth.month, startOfMonth.day);
    sl<TrainingHistoryBloc>()
        .add(SetNewDateHistoryDateEvent(startDate: startDate, endDate: now));
  }

  static void getCurrentYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final startDate =
        DateTime(startOfYear.year, startOfYear.month, startOfYear.day);
    sl<TrainingHistoryBloc>()
        .add(SetNewDateHistoryDateEvent(startDate: startDate, endDate: now));
  }
}
