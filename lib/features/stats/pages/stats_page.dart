import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
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
                  const SizedBox(height: 20),
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
