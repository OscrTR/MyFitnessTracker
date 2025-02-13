import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_period_stats.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_training.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedStatType = 0;
  StatPeriod _selectedStatPeriod = StatPeriod.week;
  double _weeklyTrainingProgress = 0;
  PeriodStats? _periodStats;
  List<HistoryTraining>? _historyTrainings;
  PeriodStats? _weeklyStats;
  int _plannedWeeklyTrainings = 0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    sl<TrainingHistoryBloc>().add(FetchHistoryEntriesEvent());
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);

    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  PeriodStats _fetchPeriodStats(StatPeriod startPeriod) {
    final historyTrainings =
        (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
            .historyTrainings;
    switch (startPeriod) {
      case StatPeriod.week:
        return PeriodStats.getCurrentWeek(historyTrainings);
      case StatPeriod.month:
        return PeriodStats.getCurrentMonth(historyTrainings);
      case StatPeriod.year:
        return PeriodStats.getCurrentYear(historyTrainings);
    }
  }

  int _calculateTotalTrainings(TrainingType? trainingType) {
    int sum = 0;
    for (var training
        in (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .trainings) {
      if (trainingType != null && training.type == trainingType) {
        sum += training.trainingDays?.length ?? 0;
      } else if (trainingType == null) {
        sum += training.trainingDays?.length ?? 0;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
            builder: (context, state) {
          if (state is TrainingManagementLoaded) {
            return Column(
              children: [
                const SizedBox(height: 30),
                _buildTrainingsList(context),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('home_page_global_stats'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 180,
                        child: CustomDropdown<String>(
                          items: StatPeriod.values
                              .map((period) =>
                                  period.translate(context.locale.languageCode))
                              .toList(),
                          initialItem: _selectedStatPeriod
                              .translate(context.locale.languageCode),
                          decoration: CustomDropdownDecoration(
                            listItemStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: AppColors.taupeGray, fontSize: 14),
                            headerStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: AppColors.taupeGray, fontSize: 14),
                            closedSuffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: AppColors.frenchGray,
                            ),
                            expandedSuffixIcon: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 20,
                              color: AppColors.frenchGray,
                            ),
                            closedBorder:
                                Border.all(color: AppColors.timberwolf),
                            expandedBorder:
                                Border.all(color: AppColors.timberwolf),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatPeriod = StatPeriod.values
                                  .firstWhere((period) =>
                                      period.translate(
                                          context.locale.languageCode) ==
                                      value);
                              _periodStats =
                                  _fetchPeriodStats(_selectedStatPeriod);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.only(
                      bottom: 15, left: 10, right: 10, top: 15),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.timberwolf),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColors.floralWhite,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ToggleSwitch(
                            customWidths: StatType.values.map((statType) {
                              // Calculer la largeur nécessaire pour chaque texte
                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: statType
                                      .translate(context.locale.languageCode),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                textDirection: ui.TextDirection.ltr,
                              )..layout();

                              return textPainter.width + 32;
                            }).toList(),
                            inactiveBgColor: AppColors.floralWhite,
                            activeBgColor: const [AppColors.white],
                            activeFgColor: AppColors.licorice,
                            inactiveFgColor: AppColors.taupeGray,
                            cornerRadius: 5,
                            radiusStyle: true,
                            initialLabelIndex: _selectedStatType,
                            totalSwitches: StatType.values.length,
                            labels: StatType.values
                                .map((statType) => statType
                                    .translate(context.locale.languageCode))
                                .toList(),
                            onToggle: (index) {
                              setState(() {
                                _selectedStatType = index!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildPeriodStats(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildHistoryList(),
                const SizedBox(height: 90)
              ],
            );
          }
          return const SizedBox();
        }),
      ),
    );
  }

  Widget _buildPeriodStats() {
    return BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
        builder: (context, state) {
      if (state is TrainingHistoryLoaded) {
        _periodStats = _fetchPeriodStats(_selectedStatPeriod);
        _weeklyStats = _fetchPeriodStats(StatPeriod.week);

        if (_selectedStatType == 0) return _buildGeneralStats(context);
        if (_selectedStatType == 1) return _buildRunStats(context);
        if (_selectedStatType == 2) return _buildWorkoutStats(context);
        if (_selectedStatType == 3) return _buildYogaStats(context);
      }
      return const SizedBox();
    });
  }

  Widget _buildHistoryList() {
    return BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
        builder: (context, state) {
      if (state is TrainingHistoryLoaded) {
        _historyTrainings = HistoryTraining.getLastTen(state.historyTrainings);

        return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _historyTrainings?.length ?? 0,
            itemBuilder: (context, index) {
              String dateFormatee =
                  DateFormat('EEEE d MMMM y', context.locale.languageCode)
                      .format(_historyTrainings![index].date);
              dateFormatee =
                  dateFormatee[0].toUpperCase() + dateFormatee.substring(1);

              final trainingName = (sl<TrainingManagementBloc>().state
                          as TrainingManagementLoaded)
                      .trainings
                      .firstWhereOrNull((trainning) =>
                          trainning.id == _historyTrainings![index].trainingId)
                      ?.name ??
                  '${_historyTrainings![index].trainingName} (${tr('global_deleted')})';

              return GestureDetector(
                onTap: () {
                  context.read<TrainingHistoryBloc>().add(
                      SelectHistoryTrainingEntryEvent(
                          _historyTrainings![index]));
                  GoRouter.of(context).push('/history_details');
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.timberwolf),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            Text(
                              dateFormatee,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                  color: AppColors.parchment,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                _historyTrainings![index]
                                    .trainingType
                                    .translate(context.locale.languageCode),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 20,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.clock, size: 16),
                                const SizedBox(width: 5),
                                Text(formatDurationToHoursMinutesSeconds(
                                    _historyTrainings![index].duration)),
                              ],
                            ),
                            if (_historyTrainings![index].distance > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.activity, size: 16),
                                  const SizedBox(width: 5),
                                  Text(
                                      '${(_historyTrainings![index].distance / 1000).toStringAsFixed(2)}km'),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.flame, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                    '${_historyTrainings![index].calories} cal'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trainingName,
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                      ],
                    )),
              );
            });
      }
      return const SizedBox();
    });
  }

  Column _buildRunStats(BuildContext context) {
    _plannedWeeklyTrainings = _calculateTotalTrainings(TrainingType.run);
    _weeklyTrainingProgress = _plannedWeeklyTrainings != 0
        ? _weeklyStats!.runTrainingsCount / _plannedWeeklyTrainings
        : 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_distance'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.runTotalDistance.toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_pace'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(formatPace(_periodStats!.runAveragePace),
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_drop'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.runTotalDrop} m',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('home_page_trainings')} ${_selectedStatPeriod == StatPeriod.week ? tr('home_page_week') : _selectedStatPeriod == StatPeriod.month ? tr('home_page_month') : tr('home_page_year')}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            if (_selectedStatPeriod != StatPeriod.week)
              Text('${_periodStats!.runTrainingsCount}',
                  style: Theme.of(context).textTheme.titleLarge)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_periodStats!.runTrainingsCount}/$_plannedWeeklyTrainings',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${(_weeklyTrainingProgress * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: AppColors.taupeGray),
                  ),
                ],
              ),
            if (_selectedStatPeriod == StatPeriod.week)
              const SizedBox(height: 5),
            if (_selectedStatPeriod == StatPeriod.week)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _weeklyTrainingProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.timberwolf,
                  color: AppColors.licorice,
                ),
              )
          ],
        ),
      ],
    );
  }

  Column _buildWorkoutStats(BuildContext context) {
    _plannedWeeklyTrainings = _calculateTotalTrainings(TrainingType.workout);
    _weeklyTrainingProgress = _plannedWeeklyTrainings != 0
        ? _weeklyStats!.workoutTrainingsCount / _plannedWeeklyTrainings
        : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_load'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.workoutTotalLoad} kg',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_sets'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.workoutTotalSets}',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_rest'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(
                    formatDurationToHoursMinutesSeconds(
                        _periodStats!.workoutTotalRest),
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('home_page_trainings')} ${_selectedStatPeriod == StatPeriod.week ? tr('home_page_week') : _selectedStatPeriod == StatPeriod.month ? tr('home_page_month') : tr('home_page_year')}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            if (_selectedStatPeriod != StatPeriod.week)
              Text('${_periodStats!.workoutTrainingsCount}',
                  style: Theme.of(context).textTheme.titleLarge)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_periodStats!.workoutTrainingsCount}/$_plannedWeeklyTrainings',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${(_weeklyTrainingProgress * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: AppColors.taupeGray),
                  ),
                ],
              ),
            if (_selectedStatPeriod == StatPeriod.week)
              const SizedBox(height: 5),
            if (_selectedStatPeriod == StatPeriod.week)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _weeklyTrainingProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.timberwolf,
                  color: AppColors.licorice,
                ),
              )
          ],
        ),
      ],
    );
  }

  Column _buildYogaStats(BuildContext context) {
    _plannedWeeklyTrainings = _calculateTotalTrainings(TrainingType.yoga);
    _weeklyTrainingProgress = _plannedWeeklyTrainings != 0
        ? _weeklyStats!.yogaTrainingsCount / _plannedWeeklyTrainings
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_duration'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(
                    formatDurationToHoursMinutesSeconds(
                        _periodStats!.yogaTotalDuration),
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_postures'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.yogaUniqueExercises}',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_meditation'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(
                    formatDurationToHoursMinutesSeconds(
                        _periodStats!.yogaTotalMeditationDuration),
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('home_page_trainings')} ${_selectedStatPeriod == StatPeriod.week ? tr('home_page_week') : _selectedStatPeriod == StatPeriod.month ? tr('home_page_month') : tr('home_page_year')}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            if (_selectedStatPeriod != StatPeriod.week)
              Text('${_periodStats!.yogaTrainingsCount}',
                  style: Theme.of(context).textTheme.titleLarge)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_weeklyStats!.yogaTrainingsCount}/$_plannedWeeklyTrainings',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${(_weeklyTrainingProgress * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: AppColors.taupeGray),
                  ),
                ],
              ),
            if (_selectedStatPeriod == StatPeriod.week)
              const SizedBox(height: 5),
            if (_selectedStatPeriod == StatPeriod.week)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _weeklyTrainingProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.timberwolf,
                  color: AppColors.licorice,
                ),
              )
          ],
        ),
      ],
    );
  }

  Column _buildGeneralStats(BuildContext context) {
    _plannedWeeklyTrainings = _calculateTotalTrainings(null);
    _weeklyTrainingProgress = _plannedWeeklyTrainings != 0
        ? _weeklyStats!.totalTrainingsCount / _plannedWeeklyTrainings
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_total_duration'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(
                    formatDurationToHoursMinutesSeconds(
                        _periodStats!.totalDuration),
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_distance'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text(
                    '${(_periodStats!.runTotalDistance / 1000).toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home_page_calories'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('${_periodStats!.totalCalories} cal',
                    style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('home_page_trainings')} ${_selectedStatPeriod == StatPeriod.week ? tr('home_page_week') : _selectedStatPeriod == StatPeriod.month ? tr('home_page_month') : tr('home_page_year')}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            if (_selectedStatPeriod != StatPeriod.week)
              Text('${_periodStats!.totalTrainingsCount}',
                  style: Theme.of(context).textTheme.titleLarge)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_weeklyStats!.totalTrainingsCount}/$_plannedWeeklyTrainings',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${(_weeklyTrainingProgress * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: AppColors.taupeGray),
                  ),
                ],
              ),
            if (_selectedStatPeriod == StatPeriod.week)
              const SizedBox(height: 5),
            if (_selectedStatPeriod == StatPeriod.week)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _weeklyTrainingProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.timberwolf,
                  color: AppColors.licorice,
                ),
              )
          ],
        ),
      ],
    );
  }
}

Widget _buildTrainingsList(BuildContext context) {
  String getDayText(WeekDay day) {
    final now = DateTime.now();
    final currentDay =
        WeekDay.values[now.weekday - 1]; // -1 car DateTime.weekday commence à 1

    if (day == currentDay) {
      return context.locale.languageCode == 'fr' ? 'Aujourd\'hui' : 'Today';
    }
    return day.translate(context.locale.languageCode);
  }

  WeekDay getNextTrainingDay(Training training) {
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;

    final sortedDays = List<WeekDay>.from(training.trainingDays!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // On cherche d'abord si le jour actuel est un jour d'entraînement
    if (sortedDays.any((day) => day.index == currentDayIndex)) {
      return sortedDays.firstWhere((day) => day.index == currentDayIndex);
    }

    // Sinon, on cherche le prochain jour d'entraînement
    return sortedDays.firstWhere(
      (day) => day.index > currentDayIndex,
      orElse: () => sortedDays
          .first, // Premier jour de la semaine suivante si aucun jour trouvé
    );
  }

  return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
    if (state is TrainingManagementLoaded) {
      final plannedTrainings = state.trainings
          .where((t) => t.trainingDays?.isNotEmpty ?? false)
          .toList()
        ..sort((a, b) {
          final now = DateTime.now();
          final currentDayIndex = now.weekday - 1;

          int getNextDayIndex(Training t) {
            final days = t.trainingDays!
              ..sort((x, y) => x.index.compareTo(y.index));
            final todayIndex =
                days.indexWhere((d) => d.index == currentDayIndex);
            if (todayIndex != -1) return currentDayIndex;
            final nextDay = days.firstWhere((d) => d.index > currentDayIndex,
                orElse: () => days.first);
            return nextDay.index;
          }

          final nextA = getNextDayIndex(a);
          final nextB = getNextDayIndex(b);

          int daysUntil(int nextDay) => nextDay < currentDayIndex
              ? (7 - currentDayIndex) + nextDay
              : nextDay - currentDayIndex;

          return daysUntil(nextA).compareTo(daysUntil(nextB));
        });

      if (plannedTrainings.isEmpty) {
        return Container(
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.floralWhite,
              border: Border.all(color: AppColors.parchment),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('home_page_first_training_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 3),
              Text(
                tr('home_page_first_training_description'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.taupeGray),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => GoRouter.of(context).push('/training_detail'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                          color: AppColors.folly,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            tr('global_start'),
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.licorice,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(tr('home_page_planned_today')),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      } else {
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plannedTrainings.length,
            itemBuilder: (context, index) {
              final training = plannedTrainings.toList()[index];
              final nextDay = getNextTrainingDay(training);

              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: 20,
                        right: index + 1 == plannedTrainings.length ? 20 : 0),
                    width: MediaQuery.of(context).size.width - 40,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.floralWhite,
                        border: Border.all(color: AppColors.parchment),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          training.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          training.type.translate(context.locale.languageCode),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.taupeGray),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<TrainingManagementBloc>()
                                    .add(StartTrainingEvent(training.id!));
                                GoRouter.of(context).push('/active_training');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                decoration: BoxDecoration(
                                    color: AppColors.folly,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      tr('global_start'),
                                      style: const TextStyle(
                                          color: AppColors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.licorice,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(getDayText(nextDay)),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 20,
                    child: PopupMenuButton(
                      constraints: const BoxConstraints(maxWidth: 100),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.timberwolf)),
                      color: AppColors.white,
                      onSelected: (value) {
                        if (value == 'edit') {
                          context
                              .read<TrainingManagementBloc>()
                              .add(GetTrainingEvent(id: training.id!));
                          GoRouter.of(context).push('/training_detail');
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          height: 30,
                          value: 'edit',
                          child: Text(
                            tr('global_edit'),
                            style: const TextStyle(color: AppColors.taupeGray),
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }
    return const SizedBox();
  });
}

enum StatType {
  all,
  run,
  workout,
  yoga;

  String translate(String locale) {
    switch (this) {
      case StatType.all:
        return locale == 'fr' ? 'Tous' : 'All';
      case StatType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case StatType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case StatType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
    }
  }
}

enum StatPeriod {
  week,
  month,
  year;

  String translate(String locale) {
    switch (this) {
      case StatPeriod.week:
        return locale == 'fr' ? 'Cette semaine' : 'This week';
      case StatPeriod.month:
        return locale == 'fr' ? 'Ce mois' : 'This month';
      case StatPeriod.year:
        return locale == 'fr' ? 'Cette année' : 'This year';
    }
  }
}
