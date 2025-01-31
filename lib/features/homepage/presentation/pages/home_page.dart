import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  double _trainingProgress = 0.2;
  List<HistoryTraining>? _filteredHistoryTrainings;
  List<HistoryTraining>? _historyTrainings;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  List<HistoryTraining> _fetchHistoryTrainings(StatPeriod startPeriod) {
    final historyTrainings =
        (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
            .historyTrainings;
    switch (startPeriod) {
      case StatPeriod.week:
        return HistoryTraining.getCurrentWeek(historyTrainings);
      case StatPeriod.month:
        return HistoryTraining.getCurrentMonth(historyTrainings);
      case StatPeriod.year:
        return HistoryTraining.getCurrentYear(historyTrainings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                    'General stats',
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
                            .copyWith(color: AppColors.taupeGray, fontSize: 14),
                        headerStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.taupeGray, fontSize: 14),
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
                        closedBorder: Border.all(color: AppColors.timberwolf),
                        expandedBorder: Border.all(color: AppColors.timberwolf),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatPeriod = StatPeriod.values.firstWhere(
                              (period) =>
                                  period
                                      .translate(context.locale.languageCode) ==
                                  value);
                          _filteredHistoryTrainings =
                              _fetchHistoryTrainings(_selectedStatPeriod);
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                            .map((statType) =>
                                statType.translate(context.locale.languageCode))
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
                  if (_selectedStatType == 0) _buildGeneralStats(context),
                  if (_selectedStatType == 1) _buildRunStats(context),
                  if (_selectedStatType == 2) _buildWorkoutStats(context),
                  if (_selectedStatType == 3) _buildYogaStats(context),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildHistoryList(),
            const SizedBox(height: 90)
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
        builder: (context, state) {
      if (state is TrainingHistoryLoaded) {
        _historyTrainings = HistoryTraining.getLastTen(state.historyTrainings);
        _filteredHistoryTrainings = _fetchHistoryTrainings(_selectedStatPeriod);

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

// TODO : rendre indépendant d'un training dans le cas d'une suppression
              final trainingName = (sl<TrainingManagementBloc>().state
                      as TrainingManagementLoaded)
                  .trainings
                  .firstWhere((trainning) =>
                      trainning.id == _historyTrainings![index].trainingId)
                  .name;

              return Container(
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.activity, size: 16),
                              const SizedBox(width: 5),
                              Text('${_historyTrainings![index].distance}km'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.flame, size: 16),
                              const SizedBox(width: 5),
                              Text('${_historyTrainings![index].calories} cal'),
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
                  ));
            });
      }
      return const SizedBox();
    });
  }

  Column _buildRunStats(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance totale',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('24.4 km', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allure moyenne',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('6:30 /km', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dénivelé',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('245 m', style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séances réalisées',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '0%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _trainingProgress,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Charge totale',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('2850 kg', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Séries totales',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('48', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repos total',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('45 min', style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séances réalisées',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '0%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _trainingProgress,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durée totale',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('0h 00min', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postures',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('12', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Méditation',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('10 min', style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séances réalisées',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '0%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _trainingProgress,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durée totale',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('0h 00min', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('0 km', style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
                Text('0 kcal', style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séances réalisées',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.taupeGray),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '0%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.taupeGray),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _trainingProgress,
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
                    width: plannedTrainings.length > 1
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width - 40,
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
                    right: 30,
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
