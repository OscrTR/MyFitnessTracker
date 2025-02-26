// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../core/enums/enums.dart';
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
    double runAveragePace = 0;
    if (runTotalDistance > 0) {
      final weightedPaceSum = runTrainings.fold<double>(
        0,
        (sum, t) => sum + (t.pace * t.distance),
      );
      runAveragePace = (weightedPaceSum / runTotalDistance);
    }

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
    final yogaUniqueExercises = yogaTrainings.fold<Set<int>>(
      {},
      (exerciseSet, t) => exerciseSet..addAll([t.exercisesCount]),
    ).length;

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
  static PeriodStats getCurrentWeek(List<HistoryTraining> trainings) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final weekTrainings = trainings
        .where((training) =>
            training.date.isAfter(startOfWeek) &&
            training.date.isBefore(endOfWeek))
        .toList();

    return PeriodStats.fromTrainings(weekTrainings);
  }

  static PeriodStats getCurrentMonth(List<HistoryTraining> trainings) {
    final now = DateTime.now();
    final monthTrainings = trainings
        .where((training) =>
            training.date.year == now.year && training.date.month == now.month)
        .toList();

    return PeriodStats.fromTrainings(monthTrainings);
  }

  static PeriodStats getCurrentYear(List<HistoryTraining> trainings) {
    final now = DateTime.now();
    final yearTrainings =
        trainings.where((training) => training.date.year == now.year).toList();

    return PeriodStats.fromTrainings(yearTrainings);
  }
}
