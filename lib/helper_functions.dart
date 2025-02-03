import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

import 'features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'features/training_management/domain/entities/training_exercise.dart';
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

String formatPace(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}/km';
}

int getCalories({required int intensity, int? reps, int? duration}) {
  double caloriesDuringExercise = 0;
  double caloriesAfterBurn = 0;
  double totalCalories = 0;
  int effectiveDuration = 0;

  const double standardWeight = 70.0;

  final Map<int, _IntensityData> intensityLevels = {
    0: _IntensityData(met: 2.0, epocFactor: 0.05),
    1: _IntensityData(met: 3.5, epocFactor: 0.08),
    2: _IntensityData(met: 5.0, epocFactor: 0.12),
    3: _IntensityData(met: 7.0, epocFactor: 0.15),
    4: _IntensityData(met: 9.0, epocFactor: 0.20),
  };

  effectiveDuration = duration ?? (reps ?? 0 * 3);

  caloriesDuringExercise = intensityLevels[intensity]!.met *
      standardWeight *
      (effectiveDuration / 60);

  caloriesAfterBurn = caloriesDuringExercise *
      intensityLevels[intensity]!.epocFactor *
      (effectiveDuration / 30);

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

String findExerciseName(TrainingExercise tExercise) {
  String exerciseName = '';
  if (tExercise.trainingExerciseType == TrainingExerciseType.run) {
    final targetIntervalDistance =
        tExercise.intervalDistance != null && tExercise.intervalDistance! > 0
            ? '${(tExercise.intervalDistance! / 1000).toStringAsFixed(1)}km'
            : '';
    final targetIntervalDuration = tExercise.intervalDuration != null
        ? formatDurationToHoursMinutesSeconds(tExercise.intervalDuration!)
        : '';
    final targetPace = tExercise.isTargetPaceSelected == true
        ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
        : '';
    final intervals = tExercise.intervals ?? 1;
    final targetDistance =
        tExercise.targetDistance != null && tExercise.targetDistance! > 0
            ? '${(tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
            : '';
    final targetDuration = tExercise.targetDuration != null
        ? formatDurationToHoursMinutesSeconds(tExercise.targetDuration!)
        : '';

    if (tExercise.runExerciseTarget == RunExerciseTarget.intervals) {
      if (tExercise.isIntervalInDistance == true) {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetIntervalDistance$targetPace';
      } else {
        exerciseName =
            '${tr('active_training_running_interval')} ${'$intervals'}x$targetIntervalDuration$targetPace';
      }
    } else if (tExercise.runExerciseTarget == RunExerciseTarget.distance) {
      exerciseName =
          '${tr('active_training_running')} $targetDistance$targetPace';
    } else if (tExercise.runExerciseTarget == RunExerciseTarget.duration) {
      exerciseName =
          '${tr('active_training_running')} $targetDuration$targetPace';
    }
  } else {
    exerciseName = (sl<ExerciseManagementBloc>().state
                as ExerciseManagementLoaded)
            .exercises
            .firstWhereOrNull((exercise) => exercise.id == tExercise.exerciseId)
            ?.name ??
        'Deleted exercise';
  }
  return exerciseName;
}
