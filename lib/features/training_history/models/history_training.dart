import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/database_service.dart';

import '../../../core/enums/enums.dart';
import '../../../injection_container.dart';
import '../../training_management/models/training.dart';
import 'history_entry.dart';
import 'history_run_location.dart';

class HistoryTraining extends Equatable {
  final Training training;
  final int trainingVersionId;
  final List<HistoryEntry> historyEntries;
  final List<RunLocation> locations;
  final int duration;
  final int distance;
  final int calories;
  final int pace;
  final int drop;
  final int load;
  final int sets;
  final int rest;
  final int exercisesCount;
  final int meditationDuration;
  final DateTime date;

  const HistoryTraining({
    required this.training,
    required this.trainingVersionId,
    required this.historyEntries,
    required this.locations,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.pace,
    required this.drop,
    required this.load,
    required this.sets,
    required this.rest,
    required this.exercisesCount,
    required this.meditationDuration,
    required this.date,
  });

  @override
  List<Object> get props {
    return [
      training,
      historyEntries,
      locations,
      duration,
      distance,
      calories,
      pace,
      drop,
      load,
      sets,
      rest,
      exercisesCount,
      meditationDuration,
      date,
    ];
  }

  static Future<List<HistoryTraining>> fromHistoryEntries(
    List<HistoryEntry> entries, {
    Map<int, List<RunLocation>>? locationsByTrainingId,
  }) async {
    // Trier les entrées par date
    final sortedEntries = [...entries]
      ..sort((a, b) => a.date.compareTo(b.date));
    // Grouper les entrées par session d'entraînement
    final groupedEntries = groupEntriesByTrainingSession(sortedEntries);
    // Résoudre les Futures pour chaque groupe
    final historyTrainings =
        await Future.wait(groupedEntries.map((group) async {
      final trainingId = group.first.trainingId;
      final locations = locationsByTrainingId?[trainingId];
      return _convertGroupToHistoryTraining(group, locations: locations);
    }));
    return historyTrainings;
  }

  static List<List<HistoryEntry>> groupEntriesByTrainingSession(
      List<HistoryEntry> entries) {
    final groups = <List<HistoryEntry>>[];
    List<HistoryEntry> currentGroup = [];

    for (var entry in entries) {
      if (currentGroup.isEmpty) {
        currentGroup.add(entry);
        continue;
      }

      final lastEntry = currentGroup.last;
      final timeDifference = entry.date.difference(lastEntry.date).inHours;

      if (lastEntry.trainingId == entry.trainingId &&
          lastEntry.date.year == entry.date.year &&
          lastEntry.date.month == entry.date.month &&
          lastEntry.date.day == entry.date.day &&
          timeDifference < 2) {
        currentGroup.add(entry);
      } else {
        groups.add(List.from(currentGroup));
        currentGroup = [entry];
      }
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }

  static Future<HistoryTraining> _convertGroupToHistoryTraining(
    List<HistoryEntry> group, {
    List<RunLocation>? locations,
  }) async {
    final firstEntry = group.first;

    final matchingTraining = (await sl<DatabaseService>()
        .getBaseTrainingByVersionId(firstEntry.trainingVersionId));

    // Calculer les statistiques agrégées
    final totalDuration = _calculateDuration(group);
    final totalDistance =
        group.fold<int>(0, (sum, entry) => sum + entry.distance);
    final totalCalories =
        group.fold<int>(0, (sum, entry) => sum + entry.calories);

    // Calculer le dénivelé si des locations sont disponibles
    final totalDrop =
        locations != null ? RunLocation.calculateTotalElevation(locations) : 0;

    final uniqueExercises = group.map((e) => e.exerciseId).toSet().length;

    final totalLoad =
        group.fold<int>(0, (sum, entry) => sum + (entry.weight * entry.reps));

    final totalSets = group.map((e) => e.setNumber).nonNulls.length;

    final averagePace = group.map((e) => e.pace).nonNulls.isEmpty
        ? 0
        : group.map((e) => e.pace).nonNulls.average.round();

    final totalRest = _calculateTotalRest(group);

    final meditationDuration =
        _calculateMeditationDuration(group, matchingTraining!);

    return HistoryTraining(
      training: matchingTraining,
      historyEntries: group,
      locations: locations ?? [],
      duration: totalDuration,
      distance: totalDistance,
      calories: totalCalories,
      pace: averagePace,
      drop: totalDrop,
      load: totalLoad,
      sets: totalSets,
      rest: totalRest,
      exercisesCount: uniqueExercises,
      meditationDuration: meditationDuration,
      date: firstEntry.date,
      trainingVersionId: firstEntry.trainingVersionId,
    );
  }

  static int _calculateMeditationDuration(
      List<HistoryEntry> group, Training training) {
    final List<int> meditationExercisesIds = training.exercises
        .where((exercise) => exercise.exerciseType == ExerciseType.meditation)
        .map((exercise) => exercise.id!)
        .toList();

    if (meditationExercisesIds.isEmpty) return 0;

    return group
        .where((entry) => meditationExercisesIds.contains(entry.exerciseId))
        .fold<int>(0, (sum, entry) => sum + entry.duration);
  }

  static int _calculateDuration(List<HistoryEntry> group) {
    int totalTrainingTime = 0;

    final firstEntry = group[0];
    final lastEntry = group[group.length - 1];
    final initialTime = firstEntry.date;
    DateTime correctedInitialTime = initialTime;

    if (firstEntry.reps != 0) {
      correctedInitialTime =
          initialTime.subtract(Duration(seconds: firstEntry.reps * 3));
    } else if (firstEntry.duration != 0) {
      correctedInitialTime =
          initialTime.subtract(Duration(seconds: firstEntry.duration));
    }

    totalTrainingTime =
        lastEntry.date.difference(correctedInitialTime).inSeconds;

    return totalTrainingTime;
  }

  static int _calculateTotalRest(List<HistoryEntry> group) {
    int totalTrainingTime = 0;
    int totalEffectiveTime = 0;

    final firstEntry = group[0];
    final lastEntry = group[group.length - 1];
    final initialTime = firstEntry.date;
    DateTime correctedInitialTime = initialTime;

    if (firstEntry.reps != 0) {
      correctedInitialTime =
          initialTime.subtract(Duration(seconds: firstEntry.reps * 3));
    } else if (firstEntry.duration != 0) {
      correctedInitialTime =
          initialTime.subtract(Duration(seconds: firstEntry.duration));
    }

    totalTrainingTime =
        lastEntry.date.difference(correctedInitialTime).inSeconds;

    // Calculer le temps total d'entraînement effectif
    for (var entry in group) {
      if (entry.duration != 0 && entry.duration > 0) {
        totalEffectiveTime += entry.duration;
      } else if (entry.reps != 0) {
        totalEffectiveTime += entry.reps * 3;
      }
    }

    // Le temps de repos est la différence entre le temps total écoulé et le temps d'entraînement
    return totalTrainingTime - totalEffectiveTime;
  }

  static List<HistoryTraining> getCurrentWeek(List<HistoryTraining> trainings) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return trainings
        .where((training) =>
            training.date.isAfter(startOfWeek) &&
            training.date.isBefore(endOfWeek))
        .toList();
  }

  static List<HistoryTraining> getCurrentMonth(
      List<HistoryTraining> trainings) {
    final now = DateTime.now();
    return trainings
        .where((training) =>
            training.date.year == now.year && training.date.month == now.month)
        .toList();
  }

  static List<HistoryTraining> getCurrentYear(List<HistoryTraining> trainings) {
    final now = DateTime.now();
    return trainings
        .where((training) => training.date.year == now.year)
        .toList();
  }

  static List<HistoryTraining> getLastTen(List<HistoryTraining> trainings) {
    final List<HistoryTraining> editableList = List.from(trainings);
    final sortedTrainings = editableList
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedTrainings.take(10).toList();
  }
}
