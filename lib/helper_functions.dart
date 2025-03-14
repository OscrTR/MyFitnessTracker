import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'core/enums/enums.dart';
import 'features/base_exercise_management/bloc/base_exercise_management_bloc.dart';
import 'features/training_management/models/exercise.dart';
import 'injection_container.dart';

String formatDurationToMinutesSeconds(int? seconds) {
  final minutes = (seconds ?? 0) ~/ 60;
  final remainingSeconds = (seconds ?? 0) % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

String formatDurationToHoursMinutesSeconds(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;
  return '${hours > 0 ? '$hours:' : ''}${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String formatDurationToApproximativeHoursMinutes(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return '~${hours > 0 ? '$hours ${tr('global_hours')}' : ''} ${minutes > 0 ? '${minutes.toString().padLeft(2, '0')} ${tr('global_minutes')}' : ''}';
}

String formatPace(double paceInMinPerKm) {
  if (paceInMinPerKm <= 0) {
    return '00:00/km';
  }
  final int minutes = paceInMinPerKm.floor();
  final int seconds = ((paceInMinPerKm - minutes) * 60).round();

  final String secondsStr = seconds.toString().padLeft(2, '0');
  return '$minutes:$secondsStr/km';
}

int getCalories(
    {required int intensity, required int? weight, int? reps, int? duration}) {
  double caloriesDuringExercise = 0;
  double caloriesAfterBurn = 0;
  double totalCalories = 0;
  double effectiveDuration = 0;

  double standardWeight =
      (weight != null && weight != 0 ? weight : 70.0).toDouble();

  final Map<int, _IntensityData> intensityLevels = {
    0: _IntensityData(met: 2.0, epocFactor: 0.05),
    1: _IntensityData(met: 3.5, epocFactor: 0.08),
    2: _IntensityData(met: 5.0, epocFactor: 0.12),
    3: _IntensityData(met: 7.0, epocFactor: 0.15),
    4: _IntensityData(met: 9.0, epocFactor: 0.20),
  };

  effectiveDuration = (duration ?? ((reps ?? 0) * 3)) / 3600;

  caloriesDuringExercise =
      intensityLevels[intensity]!.met * standardWeight * effectiveDuration;

  caloriesAfterBurn =
      caloriesDuringExercise * intensityLevels[intensity]!.epocFactor;

  totalCalories = caloriesDuringExercise + caloriesAfterBurn;

  return totalCalories.round();
}

class _IntensityData {
  final double met;
  final double epocFactor;

  _IntensityData({
    required this.met,
    required this.epocFactor,
  });
}

String findExerciseName(Exercise exercise) {
  String exerciseName = '';
  if (exercise.exerciseType == ExerciseType.running) {
    final targetPace = exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(exercise.targetPace)}'
        : '';
    final intervals = exercise.sets;
    final targetDistance =
        '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km';
    final targetDuration =
        formatDurationToHoursMinutesSeconds(exercise.targetDuration);

    if (intervals > 1) {
      if (exercise.runType == RunType.distance) {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetDistance$targetPace';
      } else {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetDuration$targetPace';
      }
    } else if (exercise.runType == RunType.distance) {
      exerciseName =
          '${tr('active_training_running')} $targetDistance$targetPace';
    } else if (exercise.runType == RunType.duration) {
      exerciseName =
          '${tr('active_training_running')} $targetDuration$targetPace';
    }
  } else {
    exerciseName =
        (sl<BaseExerciseManagementBloc>().state as BaseExerciseManagementLoaded)
                .baseExercises
                .firstWhereOrNull((b) => b.id == exercise.baseExerciseId)
                ?.name ??
            'Deleted exercise';
  }
  return exerciseName;
}

String formatDateLabel(
    BuildContext context, DateTime date, bool isWeekSelected) {
  final currentLocale = context.locale;
  final label =
      DateFormat(isWeekSelected ? 'MMM d' : 'MMM', currentLocale.toString())
          .format(date);
  return capitalizeFirstLetter(label);
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

void scrollToMostRecentDate(ScrollController scrollController) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  });
}

Map<T, bool> createMapWithDefaultValues<T>(List<T> enumValues) {
  return Map.fromEntries(enumValues
      .sublist(0, enumValues.length - 1)
      .map((value) => MapEntry(value, false)));
}

class NotificationIdGenerator {
  // On initialise le compteur avec une valeur basée sur le timestamp en microsecondes, puis on réduit à 5 chiffres
  static int _counter = DateTime.now().microsecondsSinceEpoch % 100000;

  static int getNextId() {
    // Retourne l'id courant et l'incrémente ensuite. On s'assure que le résultat reste dans 5 chiffres.
    return _counter++ % 100000;
  }
}

double paceMSToMinPerKm(double speedMS) {
  if (speedMS <= 0) {
    return 0;
  }
  // Calcul du pace en minutes par km
  double pace = 1000 / (speedMS * 60);
  return pace;
}

double calculateAverage(List<double> list) {
  if (list.isEmpty) {
    return 0.0;
  }
  double sum = list.reduce((a, b) => a + b);
  return sum / list.length;
}
