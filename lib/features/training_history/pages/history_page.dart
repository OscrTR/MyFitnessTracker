import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/back_button_behavior.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../training_management/bloc/training_management_bloc.dart';
import '../models/history_training.dart';
import '../bloc/training_history_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollToMostRecentDate(_scrollController);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return backButtonClick(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
              builder: (context, state) {
            if (state is TrainingHistoryLoaded) {
              final historyTrainings =
                  HistoryTraining.getLastTen(state.historyTrainings);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('history_page_title'),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  _buildDateTypeSelection(context, state),
                  const SizedBox(height: 10),
                  _buildDatesList(state),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      ...state.selectedTrainingTypes.keys.map(
                        (e) => FilterChip(
                          side: BorderSide(
                              color: state.selectedTrainingTypes[e]!
                                  ? AppColors.white
                                  : AppColors.timberwolf),
                          label: Text(
                            e.translate(context.locale.languageCode),
                          ),
                          labelStyle: TextStyle(
                            color: state.selectedTrainingTypes[e]!
                                ? AppColors.white
                                : AppColors.licorice,
                          ),
                          showCheckmark: true,
                          selectedColor: AppColors.licorice,
                          checkmarkColor: AppColors.white,
                          backgroundColor: AppColors.white,
                          selected: state.selectedTrainingTypes[e]!,
                          onSelected: (bool value) {
                            setState(() {
                              context
                                  .read<TrainingHistoryBloc>()
                                  .add(SelectTrainingTypeEvent(e, value));
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (historyTrainings.isNotEmpty)
                    _buildEntriesList(state, historyTrainings)
                  else
                    Expanded(
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

  ToggleSwitch _buildDateTypeSelection(
      BuildContext context, TrainingHistoryLoaded state) {
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
      initialLabelIndex: state.isWeekSelected ? 0 : 1,
      totalSwitches: 2,
      labels: [tr('global_week'), tr('global_month')],
      onToggle: (index) {
        context
            .read<TrainingHistoryBloc>()
            .add(FetchHistoryEntriesEvent(index == 0 ? true : false));
        scrollToMostRecentDate(_scrollController);
      },
    );
  }

  SizedBox _buildDatesList(TrainingHistoryLoaded state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: state.isWeekSelected
            ? state.weeksList.length
            : state.monthsList.length,
        itemBuilder: (context, index) {
          final date = state.isWeekSelected
              ? state.weeksList[index]
              : state.monthsList[index];

          final label = formatDateLabel(context, date, state.isWeekSelected);

          final isSelected = state.isWeekSelected
              ? date.year == state.startDate.year &&
                  date.month == state.startDate.month &&
                  date.day == state.startDate.day
              : date.year == state.startDate.year &&
                  date.month == state.startDate.month;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                context
                    .read<TrainingHistoryBloc>()
                    .add(SetNewDateHistoryDateEvent(startDate: date));
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

  ListView _buildEntriesList(
      TrainingHistoryLoaded state, List<HistoryTraining> historyTrainings) {
    final hasSelectedTypes =
        state.selectedTrainingTypes.values.any((isSelected) => isSelected);

    final displayedEntries = hasSelectedTypes
        ? historyTrainings
            .where((entry) =>
                state.selectedTrainingTypes[entry.training.trainingType] ??
                false)
            .toList()
        : historyTrainings;

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedEntries.length,
        itemBuilder: (context, index) {
          String dateFormatee =
              DateFormat('EEEE d MMMM y', context.locale.languageCode)
                  .format(displayedEntries[index].date);
          dateFormatee =
              dateFormatee[0].toUpperCase() + dateFormatee.substring(1);

          final trainingName = (sl<TrainingManagementBloc>().state
                      as TrainingManagementLoaded)
                  .trainings
                  .firstWhereOrNull((trainning) =>
                      trainning.id == displayedEntries[index].training.id)
                  ?.name ??
              '${displayedEntries[index].training.name} (${tr('global_deleted')})';

          return GestureDetector(
            onTap: () {
              context.read<TrainingHistoryBloc>().add(
                  SelectHistoryTrainingEntryEvent(displayedEntries[index]));
              GoRouter.of(context).go('/history_details');
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
                            displayedEntries[index]
                                .training
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
                                displayedEntries[index].duration)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.activity, size: 16),
                            const SizedBox(width: 5),
                            Text(
                                '${(displayedEntries[index].distance / 1000).toStringAsFixed(2)}km'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.flame, size: 16),
                            const SizedBox(width: 5),
                            Text('${displayedEntries[index].calories} cal'),
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
