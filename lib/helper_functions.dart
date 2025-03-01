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

String formatPace(double speed) {
  if (speed <= 0) {
    return '00:00/km';
  }
  final double paceInMinutes = (1000 / speed) / 60;
  final int minutes = paceInMinutes.floor();
  final int seconds = ((paceInMinutes - minutes) * 60).round();

  // Formater les secondes pour toujours afficher deux chiffres.
  final String secondsStr = seconds.toString().padLeft(2, '0');
  return '$minutes:$secondsStr/km';
}

int getCalories({required int intensity, int? reps, int? duration}) {
  double caloriesDuringExercise = 0;
  double caloriesAfterBurn = 0;
  double totalCalories = 0;
  double effectiveDuration = 0;

  const double standardWeight = 70.0;

  final Map<int, _IntensityData> intensityLevels = {
    0: _IntensityData(met: 2.0, epocFactor: 0.05),
    1: _IntensityData(met: 3.5, epocFactor: 0.08),
    2: _IntensityData(met: 5.0, epocFactor: 0.12),
    3: _IntensityData(met: 7.0, epocFactor: 0.15),
    4: _IntensityData(met: 9.0, epocFactor: 0.20),
  };

  effectiveDuration = (duration ?? (reps ?? 0 * 3)) / 3600;

  caloriesDuringExercise =
      intensityLevels[intensity]!.met * standardWeight * effectiveDuration;

  caloriesAfterBurn =
      caloriesDuringExercise * intensityLevels[intensity]!.epocFactor;

  totalCalories = caloriesDuringExercise + caloriesAfterBurn;

  return totalCalories.toInt();
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
    final targetSpeed = exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(exercise.targetSpeed)}'
        : '';
    final intervals = exercise.sets;
    final targetDistance =
        '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km';
    final targetDuration =
        formatDurationToHoursMinutesSeconds(exercise.targetDuration);

    if (intervals > 1) {
      if (exercise.runType == RunType.distance) {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetDistance$targetSpeed';
      } else {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetDuration$targetSpeed';
      }
    } else if (exercise.runType == RunType.distance) {
      exerciseName =
          '${tr('active_training_running')} $targetDistance$targetSpeed';
    } else if (exercise.runType == RunType.duration) {
      exerciseName =
          '${tr('active_training_running')} $targetDuration$targetSpeed';
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
