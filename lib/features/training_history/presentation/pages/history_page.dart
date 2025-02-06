import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';
import '../../domain/entities/history_training.dart';
import '../bloc/training_history_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isWeekSelected = true;
  List<DateTime> _weeksList = [];
  List<DateTime> _monthsList = [];
  List<HistoryTraining>? _historyTrainings;
  final ScrollController _scrollController = ScrollController();

  String _formatDateLabel(
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

  List<DateTime> _generateWeeklyRanges() {
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

  List<DateTime> _generateMonthlyRanges() {
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

  DateTime _getLastDayOfCurrentMonth() {
    final now = DateTime.now();
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
    final firstDayOfNextMonth = DateTime(nextMonthYear, nextMonth, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  DateTime _calculateEndOfWeek() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final daysUntilEndOfWeek = DateTime.sunday - endOfDay.weekday;
    return endOfDay.add(Duration(days: daysUntilEndOfWeek));
  }

  void _scrollToMostRecentDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    _weeksList = _generateWeeklyRanges();
    _monthsList = _generateMonthlyRanges();
    _scrollToMostRecentDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
              builder: (context, state) {
            if (state is TrainingHistoryLoaded) {
              _historyTrainings =
                  HistoryTraining.getLastTen(state.historyTrainings);

              final historyEntries = state.historyEntries;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('history_page_title'),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  _buildDateTypeSelection(context),
                  const SizedBox(height: 10),
                  _buildDatesList(state),
                  if (historyEntries.isNotEmpty)
                    _buildEntriesList()
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 250,
                      child:
                          Center(child: Text(tr('history_page_no_training'))),
                    ),
                ],
              );
            }
            return const SizedBox();
          })),
    );
  }

  ToggleSwitch _buildDateTypeSelection(BuildContext context) {
    return ToggleSwitch(
      minWidth: (MediaQuery.of(context).size.width - 40) / 2,
      inactiveBgColor: AppColors.whiteSmoke,
      activeBgColor: const [AppColors.licorice],
      activeFgColor: AppColors.white,
      inactiveFgColor: AppColors.licorice,
      borderColor: const [AppColors.timberwolf],
      borderWidth: 1,
      cornerRadius: 10,
      radiusStyle: true,
      initialLabelIndex: _isWeekSelected ? 0 : 1,
      totalSwitches: 2,
      labels: [tr('global_week'), tr('global_month')],
      onToggle: (index) {
        setState(() {
          _isWeekSelected = index == 0 ? true : false;
          context.read<TrainingHistoryBloc>().add(SetDefaultHistoryDateEvent());
          _scrollToMostRecentDate();
        });
      },
    );
  }

  SizedBox _buildDatesList(TrainingHistoryLoaded state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _isWeekSelected ? _weeksList.length : _monthsList.length,
        itemBuilder: (context, index) {
          final date = _isWeekSelected ? _weeksList[index] : _monthsList[index];

          final label = _formatDateLabel(context, date, _isWeekSelected);

          final isSelected = _isWeekSelected
              ? date.year == state.startDate.year &&
                  date.month == state.startDate.month &&
                  date.day == state.startDate.day
              : date.year == state.startDate.year &&
                  date.month == state.startDate.month;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                context.read<TrainingHistoryBloc>().add(
                    SetNewDateHistoryDateEvent(
                        startDate: date, isWeekSelected: _isWeekSelected));
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected
                            ? AppColors.licorice
                            : AppColors.timberwolf),
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? AppColors.licorice : AppColors.white),
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppColors.white : AppColors.licorice),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ListView _buildEntriesList() {
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
                  SelectHistoryTrainingEntryEvent(_historyTrainings![index]));
              GoRouter.of(context).push('/history_details');
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 20),
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
                            Text(
                                '${(_historyTrainings![index].distance / 1000).toStringAsFixed(2)}km'),
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
                )),
          );
        });
  }
}
