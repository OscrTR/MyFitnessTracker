import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/features/base_exercise_management/bloc/base_exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/bloc/training_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/models/training.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../../training_history/bloc/training_history_bloc.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollToMostRecentDate(_scrollController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
              builder: (context, state) {
            if (state is TrainingHistoryLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('stats_page_title'),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  _buildDateTypeSelection(context, state),
                  const SizedBox(height: 10),
                  _buildDatesList(state),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 4,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 40,
                          width: 1,
                          color: AppColors.licorice,
                        ),
                      ),
                      FilterChip(
                        side: BorderSide(
                            color: state.isExercisesSelected
                                ? AppColors.white
                                : AppColors.timberwolf),
                        label: Text(
                          tr('exercise_page_exercises'),
                        ),
                        labelStyle: TextStyle(
                          color: state.isExercisesSelected
                              ? AppColors.white
                              : AppColors.licorice,
                        ),
                        showCheckmark: true,
                        selectedColor: AppColors.licorice,
                        checkmarkColor: AppColors.white,
                        backgroundColor: AppColors.white,
                        selected: state.isExercisesSelected,
                        onSelected: (bool value) {
                          setState(() {
                            context
                                .read<TrainingHistoryBloc>()
                                .add(SelectExercisesEvent(value));
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  if (state.isExercisesSelected)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40 - 60,
                          child: CustomDropdown<BaseExercise>.search(
                            closedHeaderPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            items: (context
                                    .read<BaseExerciseManagementBloc>()
                                    .state as BaseExerciseManagementLoaded)
                                .baseExercises,
                            hintText: tr('exercise_search'),
                            initialItem: state.selectedStatsBaseExercise,
                            decoration: CustomDropdownDecoration(
                              closedBorderRadius: BorderRadius.circular(10),
                              expandedBorderRadius: BorderRadius.circular(10),
                              closedErrorBorderRadius:
                                  BorderRadius.circular(10),
                              listItemStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.timberwolf),
                              headerStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.licorice),
                              closedSuffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.timberwolf,
                              ),
                              expandedSuffixIcon: const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 20,
                                color: AppColors.timberwolf,
                              ),
                              closedBorder:
                                  Border.all(color: AppColors.timberwolf),
                              expandedBorder:
                                  Border.all(color: AppColors.timberwolf),
                            ),
                            headerBuilder: (context, selectedItem, enabled) {
                              return Text(selectedItem.name);
                            },
                            listItemBuilder:
                                (context, item, isSelected, onItemSelect) {
                              return Text(item.name);
                            },
                            onChanged: (value) {
                              context
                                  .read<TrainingHistoryBloc>()
                                  .add(SelectBaseExerciseEvent(value));
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              context
                                  .read<TrainingHistoryBloc>()
                                  .add(SelectBaseExerciseEvent(null));
                            },
                            icon: Icon(LucideIcons.rotateCcw))
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40 - 60,
                          child: CustomDropdown<Training>.search(
                            closedHeaderPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            items: (context.read<TrainingManagementBloc>().state
                                    as TrainingManagementLoaded)
                                .trainings,
                            hintText: tr('stats_page_training_search'),
                            initialItem: state.selectedStatsTraining,
                            decoration: CustomDropdownDecoration(
                              closedBorderRadius: BorderRadius.circular(10),
                              expandedBorderRadius: BorderRadius.circular(10),
                              closedErrorBorderRadius:
                                  BorderRadius.circular(10),
                              listItemStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.timberwolf),
                              headerStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.licorice),
                              closedSuffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.timberwolf,
                              ),
                              expandedSuffixIcon: const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 20,
                                color: AppColors.timberwolf,
                              ),
                              closedBorder:
                                  Border.all(color: AppColors.timberwolf),
                              expandedBorder:
                                  Border.all(color: AppColors.timberwolf),
                            ),
                            headerBuilder: (context, selectedItem, enabled) {
                              return Text(selectedItem.name);
                            },
                            listItemBuilder:
                                (context, item, isSelected, onItemSelect) {
                              return Text(item.name);
                            },
                            onChanged: (value) {
                              context
                                  .read<TrainingHistoryBloc>()
                                  .add(SelectTrainingEvent(value));
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              context
                                  .read<TrainingHistoryBloc>()
                                  .add(SelectTrainingEvent(null));
                            },
                            icon: Icon(LucideIcons.rotateCcw))
                      ],
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
}
