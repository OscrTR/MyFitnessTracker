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
