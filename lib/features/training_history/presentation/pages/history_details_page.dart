import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:collection/collection.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/history_entry.dart';

class HistoryDetailsPage extends StatefulWidget {
  const HistoryDetailsPage({super.key});

  @override
  State<HistoryDetailsPage> createState() => _HistoryDetailsPageState();
}

class _HistoryDetailsPageState extends State<HistoryDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
        builder: (context, state) {
      if (state is TrainingHistoryLoaded &&
          state.selectedTrainingEntry != null) {
        final matchingTraining =
            (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
                .trainings
                .firstWhereOrNull((training) =>
                    training.id == state.selectedTrainingEntry!.trainingId);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(context, state, matchingTraining),
              const SizedBox(height: 10),
              if (matchingTraining != null)
                _buildMatchingTraining()
              else
                _buildNoMatchTraining(context, state)
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildMatchingTraining() {
    return Text('Matching training');
  }

  Widget _buildNoMatchTraining(
      BuildContext context, TrainingHistoryLoaded state) {
    Map<int, List<HistoryEntry>> groupedEntries = groupBy(
        state.selectedTrainingEntry!.historyEntries,
        (HistoryEntry entry) => entry.trainingExerciseId);

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedEntries.length,
        itemBuilder: (context, index) {
          int trainingExerciseId = groupedEntries.keys.elementAt(index);
          List<HistoryEntry> entries = groupedEntries[trainingExerciseId]!;

          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.timberwolf),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entries[0].exerciseNameAtTime),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sets',
                        style: TextStyle(color: AppColors.taupeGray)),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              entries[0].weight != null ? 'Kg' : '',
                              style:
                                  const TextStyle(color: AppColors.taupeGray),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (entries[0].reps != null)
                          const SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(
                                'Reps',
                                style: TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          )
                        else
                          const SizedBox(
                            width: 70,
                            child: Center(
                              child: Text(
                                'Duration',
                                style: TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ...entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.trainingExerciseType !=
                          TrainingExerciseType.run)
                        _buildExerciseFields(entry)
                      else
                        _buildRunExerciseFields(entry)
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildExerciseFields(HistoryEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${(entry.setNumber ?? 0) + 1}'),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${entry.weight ?? ''}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            if (entry.reps != null)
              SizedBox(
                width: 50,
                child: Text(
                  '${entry.reps}',
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                width: 70,
                child: Text(
                  formatDurationToHoursMinutesSeconds(entry.duration ?? 0),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunExerciseFields(HistoryEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${(entry.setNumber ?? 0) + 1}'),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${entry.distance ?? 0}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                formatDurationToHoursMinutesSeconds(entry.duration ?? 0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                formatPace(entry.pace ?? 0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Stack _buildHeader(
      BuildContext context, TrainingHistoryLoaded state, Training? training) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              GoRouter.of(context).go('/home');
            },
            child: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.licorice,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(state.selectedTrainingEntry!.date),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Text(
                training != null
                    ? training.name
                    : '${state.selectedTrainingEntry!.trainingName} (${tr('global_deleted')})',
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              context.read<TrainingHistoryBloc>().add(
                  DeleteHistoryTrainingEvent(
                      historyTraining: state.selectedTrainingEntry!));
              GoRouter.of(context).go('/home');
            },
            child: const Icon(
              LucideIcons.trash,
              color: AppColors.licorice,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
