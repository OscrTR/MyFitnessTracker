part of 'training_history_bloc.dart';

abstract class TrainingHistoryState extends Equatable {
  const TrainingHistoryState();

  @override
  List<Object?> get props => [];
}

class TrainingHistoryInitial extends TrainingHistoryState {}

class TrainingHistoryLoading extends TrainingHistoryState {}

class TrainingHistoryLoaded extends TrainingHistoryState {
  final List<HistoryTraining> historyTrainings;
  final PeriodStats periodStats;
  final DateTime startDate;
  final DateTime endDate;
  final bool isWeekSelected;
  final List<DateTime> weeksList;
  final List<DateTime> monthsList;
  final HistoryTraining? selectedTrainingEntry;
  final Training? selectedTraining;
  final Map<TrainingType, bool> selectedTrainingTypes;
  final bool isExercisesSelected;
  final BaseExercise? selectedStatsBaseExercise;
  final Training? selectedStatsTraining;

  const TrainingHistoryLoaded({
    required this.historyTrainings,
    required this.periodStats,
    required this.startDate,
    required this.endDate,
    this.isWeekSelected = true,
    this.weeksList = const [],
    this.monthsList = const [],
    this.selectedTrainingEntry,
    this.selectedTraining,
    this.selectedTrainingTypes = const {},
    this.isExercisesSelected = false,
    this.selectedStatsBaseExercise,
    this.selectedStatsTraining,
  });

  factory TrainingHistoryLoaded.withDefaultLists({
    required List<HistoryTraining> historyTrainings,
    required PeriodStats periodStats,
    required DateTime startDate,
    required DateTime endDate,
    bool isWeekSelected = true,
    HistoryTraining? selectedTrainingEntry,
    Training? selectedTraining,
    Map<TrainingType, bool> selectedTrainingTypes = const {},
  }) {
    return TrainingHistoryLoaded(
      historyTrainings: historyTrainings,
      periodStats: periodStats,
      startDate: startDate,
      endDate: endDate,
      isWeekSelected: isWeekSelected,
      weeksList: _generateWeeklyRanges(),
      monthsList: _generateMonthlyRanges(),
      selectedTrainingEntry: selectedTrainingEntry,
      selectedTrainingTypes: createMapWithDefaultValues(TrainingType.values),
      selectedTraining: selectedTraining,
    );
  }

  TrainingHistoryLoaded copyWith({
    List<HistoryTraining>? historyTrainings,
    PeriodStats? periodStats,
    DateTime? startDate,
    DateTime? endDate,
    HistoryTraining? selectedTrainingEntry,
    Training? selectedTraining,
    bool? isWeekSelected,
    Map<TrainingType, bool>? selectedTrainingTypes,
    bool? isExercisesSelected,
    BaseExercise? selectedStatsBaseExercise,
    Training? selectedStatsTraining,
    bool? resetSelectedStatsBaseExercise,
    bool? resetSelectedStatsTraining,
  }) {
    return TrainingHistoryLoaded(
      historyTrainings: historyTrainings ?? this.historyTrainings,
      periodStats: periodStats ?? this.periodStats,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedTrainingEntry:
          selectedTrainingEntry ?? this.selectedTrainingEntry,
      selectedTraining: selectedTraining ?? this.selectedTraining,
      isWeekSelected: isWeekSelected ?? this.isWeekSelected,
      weeksList: weeksList,
      monthsList: monthsList,
      selectedTrainingTypes:
          selectedTrainingTypes ?? this.selectedTrainingTypes,
      isExercisesSelected: isExercisesSelected ?? this.isExercisesSelected,
      selectedStatsBaseExercise: resetSelectedStatsBaseExercise == true
          ? null
          : selectedStatsBaseExercise ?? this.selectedStatsBaseExercise,
      selectedStatsTraining: resetSelectedStatsTraining == true
          ? null
          : selectedStatsTraining ?? this.selectedStatsTraining,
    );
  }

  @override
  List<Object?> get props => [
        historyTrainings,
        periodStats,
        startDate,
        endDate,
        selectedTrainingEntry,
        isWeekSelected,
        selectedTrainingTypes,
        weeksList,
        monthsList,
        selectedTraining,
        isExercisesSelected,
        selectedStatsBaseExercise,
        selectedStatsTraining
      ];

  static List<DateTime> _generateWeeklyRanges() {
    List<DateTime> ranges = [];
    DateTime now = DateTime.now();

    // Calcul du premier lundi de l'année
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    int daysUntilFirstMonday =
        (DateTime.monday - firstDayOfYear.weekday + 7) % 7;
    DateTime firstMondayOfYear =
        firstDayOfYear.add(Duration(days: daysUntilFirstMonday));

    // Calcul de la date d'il y a 3 mois
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    // Trouver le premier lundi après threeMonthsAgo
    int daysUntilMonday = (DateTime.monday - threeMonthsAgo.weekday + 7) % 7;
    DateTime firstMondayThreeMonthsAgo =
        threeMonthsAgo.add(Duration(days: daysUntilMonday));

    // Choisir la date de début appropriée
    DateTime startDate;
    if (now.difference(firstMondayOfYear).inDays < 90) {
      startDate = firstMondayThreeMonthsAgo;
    } else {
      startDate = firstMondayOfYear;
    }

    final endDate = _calculateEndOfWeek();
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      ranges.add(current);
      current = current.add(const Duration(days: 7));
    }

    return ranges;
  }

  static List<DateTime> _generateMonthlyRanges() {
    List<DateTime> ranges = [];
    DateTime now = DateTime.now();

    // Calcul de la date de début (au minimum 3 mois avant aujourd'hui)
    DateTime startDate;
    if (now.month > 3) {
      // Si on reste dans la même année
      startDate = DateTime(now.year, now.month - 2, 1);
    } else {
      // Si on doit aller chercher dans l'année précédente
      int monthsInPreviousYear = 3 - now.month;
      startDate = DateTime(now.year - 1, 12 - monthsInPreviousYear + 1, 1);
    }

    // Utiliser comme date de début la plus ancienne entre le 1er janvier et 3 mois en arrière
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    startDate = startDate.isBefore(firstDayOfYear) ? startDate : firstDayOfYear;

    final lastDay = _getLastDayOfCurrentMonth();
    DateTime current = startDate;

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      ranges.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    return ranges;
  }

  static DateTime _getLastDayOfCurrentMonth() {
    final now = DateTime.now();
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
    final firstDayOfNextMonth = DateTime(nextMonthYear, nextMonth, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  static DateTime _calculateEndOfWeek() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final daysUntilEndOfWeek = DateTime.sunday - endOfDay.weekday;
    return endOfDay.add(Duration(days: daysUntilEndOfWeek));
  }
}

class TrainingHistoryFailure extends TrainingHistoryState {}
