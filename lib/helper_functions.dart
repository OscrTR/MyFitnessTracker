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
