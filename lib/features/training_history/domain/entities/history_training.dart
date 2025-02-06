import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import 'history_entry.dart';
import 'history_run_location.dart';

class HistoryTraining extends Equatable {
  final List<HistoryEntry> historyEntries;
  final Map<int, List<RunLocation>> locationsByExerciseId;
  final int trainingId;
  final String trainingName;
  final TrainingType trainingType;
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
    required this.historyEntries,
    required this.locationsByExerciseId,
    required this.trainingId,
    required this.trainingName,
    required this.trainingType,
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
      historyEntries,
      trainingId,
      trainingName,
      trainingType,
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

  static List<HistoryTraining> fromHistoryEntries(
    List<HistoryEntry> entries, {
    Map<int, List<RunLocation>>? locationsByTrainingId,
  }) {
    final sortedEntries = entries..sort((a, b) => a.date.compareTo(b.date));
    final groupedEntries = groupEntriesByTrainingSession(sortedEntries);
    return groupedEntries.map((group) {
      final trainingId = group.first.trainingId;
      final locations = locationsByTrainingId?[trainingId];

      final locationsByExerciseId = <int, List<RunLocation>>{};
      if (locations != null) {
        for (var entry in group) {
          final exerciseLocations = locations
              .where(
                  (loc) => loc.trainingExerciseId == entry.trainingExerciseId)
              .toList();
          if (exerciseLocations.isNotEmpty) {
            locationsByExerciseId[entry.trainingExerciseId] = exerciseLocations;
          }
        }
      }

      return _convertGroupToHistoryTraining(
        group,
        locations: locations,
        locationsByExerciseId: locationsByExerciseId,
      );
    }).toList();
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

  static HistoryTraining _convertGroupToHistoryTraining(
    List<HistoryEntry> group, {
    List<RunLocation>? locations,
    Map<int, List<RunLocation>>? locationsByExerciseId,
  }) {
    final firstEntry = group.first;

    // Calculer les statistiques agrégées
    final totalDuration = _calculateDuration(group);
    final totalDistance =
        group.fold<int>(0, (sum, entry) => sum + (entry.distance ?? 0));
    final totalCalories =
        group.fold<int>(0, (sum, entry) => sum + (entry.calories ?? 0));

    // Calculer le dénivelé si des locations sont disponibles
    final totalDrop =
        locations != null ? RunLocation.calculateTotalDrop(locations) : 0;

    final uniqueExercises =
        group.map((e) => e.trainingExerciseId).toSet().length;

    final totalLoad = group.fold<int>(
        0, (sum, entry) => sum + ((entry.weight ?? 0) * (entry.reps ?? 1)));

    final totalSets = group.map((e) => e.setNumber).nonNulls.length;

    final averagePace = group.map((e) => e.pace).nonNulls.isEmpty
        ? 0
        : group.map((e) => e.pace).nonNulls.average.round();

    final totalRest = _calculateTotalRest(group);

    final meditationDuration = _calculateMeditationDuration(group);

    return HistoryTraining(
      historyEntries: group,
      locationsByExerciseId: locationsByExerciseId ?? {},
      trainingId: firstEntry.trainingId,
      trainingName: firstEntry.trainingNameAtTime,
      trainingType: firstEntry.trainingType,
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
    );
  }

  static int _calculateMeditationDuration(List<HistoryEntry> group) {
    return group
        .where((entry) =>
            entry.trainingExerciseType == TrainingExerciseType.meditation)
        .fold<int>(0, (sum, entry) => sum + (entry.duration ?? 0));
  }

  static int _calculateDuration(List<HistoryEntry> group) {
    if (group.length <= 1) return 0;

    int totalTrainingTime = 0;

    // Calculer le temps total d'entraînement effectif
    for (var entry in group) {
      if (entry.duration != null && entry.duration! > 0) {
        totalTrainingTime += entry.duration!;
      } else if (entry.reps != null) {
        // Si pas de durée mais des répétitions, on compte 3 secondes par répétition
        totalTrainingTime += entry.reps! * 3;
      }
    }

    // Le temps de repos est la différence entre le temps total écoulé et le temps d'entraînement
    return totalTrainingTime;
  }

  static int _calculateTotalRest(List<HistoryEntry> group) {
    if (group.length <= 1) return 0;

    int totalTrainingTime = 0;
    int totalElapsedTime = 0;

    // Calculer le temps total d'entraînement effectif
    for (var entry in group) {
      if (entry.duration != null && entry.duration! > 0) {
        totalTrainingTime += entry.duration!;
      } else if (entry.reps != null) {
        // Si pas de durée mais des répétitions, on compte 3 secondes par répétition
        totalTrainingTime += entry.reps! * 3;
      }
    }

    // Calculer le temps total écoulé entre la première et la dernière entrée
    for (int i = 1; i < group.length; i++) {
      final timeDifference =
          group[i].date.difference(group[i - 1].date).inSeconds;
      totalElapsedTime += timeDifference;
    }

    if ((totalElapsedTime - totalTrainingTime) < 0) {
      return 0;
    }

    // Le temps de repos est la différence entre le temps total écoulé et le temps d'entraînement
    return totalElapsedTime - totalTrainingTime;
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
