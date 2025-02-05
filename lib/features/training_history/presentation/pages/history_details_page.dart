import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:collection/collection.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../training_management/domain/entities/multiset.dart';
import '../../domain/entities/history_entry.dart';

class HistoryDetailsPage extends StatelessWidget {
  const HistoryDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
          builder: (context, state) {
        if (state is TrainingHistoryLoaded &&
            state.selectedTrainingEntry != null) {
          final matchingTraining =
              (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
                  .trainings
                  .firstWhereOrNull((training) =>
                      training.id == state.selectedTrainingEntry!.trainingId);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(context, state, matchingTraining),
                  const SizedBox(height: 10),
                  if (matchingTraining != null)
                    _buildMatchingTraining(matchingTraining, state)
                  else
                    _buildNoMatchTraining(context, state)
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget _buildMatchingTraining(
      Training training, TrainingHistoryLoaded state) {
    final sortedItems = [
      ...training.trainingExercises.map((e) => {'type': 'exercise', 'data': e}),
      ...training.multisets.map((m) => {'type': 'multiset', 'data': m}),
    ];
    sortedItems.sort((a, b) {
      final aPos = (a['data'] as dynamic).position ?? 0;
      final bPos = (b['data'] as dynamic).position ?? 0;
      return aPos.compareTo(bPos);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        if (item['type'] == 'exercise') {
          final tExercise = item['data'] as TrainingExercise;
          final isSetsInReps = tExercise.isSetsInReps ?? true;
          final matchingExercise =
              (sl<ExerciseManagementBloc>().state as ExerciseManagementLoaded)
                  .exercises
                  .firstWhereOrNull((e) => e.id == tExercise.exerciseId);

          return tExercise.trainingExerciseType == TrainingExerciseType.run
              ? Text('RUN')
              : Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.timberwolf),
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white),
                      child: Column(
                        children: [
                          _buildExerciseHeader(matchingExercise, tExercise,
                              context, isSetsInReps),
                          const SizedBox(height: 10),
                          const Divider(
                            color: AppColors.timberwolf,
                          ),
                          const SizedBox(height: 10),
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
                                        isSetsInReps ? 'Kg' : '',
                                        style: const TextStyle(
                                            color: AppColors.taupeGray),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (isSetsInReps)
                                    const SizedBox(
                                      width: 50,
                                      child: Center(
                                        child: Text(
                                          'Reps',
                                          style: TextStyle(
                                              color: AppColors.taupeGray),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(
                                      width: 70,
                                      child: Center(
                                        child: Text(
                                          'Duration',
                                          style: TextStyle(
                                              color: AppColors.taupeGray),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tExercise.sets ?? 0,
                              itemBuilder: (context, index) {
                                final matchingEntry = state
                                    .selectedTrainingEntry!.historyEntries
                                    .firstWhereOrNull((entry) =>
                                        entry.trainingExerciseId ==
                                            tExercise.id &&
                                        entry.setNumber == index);

                                final setWeight = matchingEntry?.weight ?? 0;
                                final setReps = matchingEntry?.reps ?? 0;
                                final setDuration =
                                    matchingEntry?.duration ?? 0;

                                return Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${index + 1}',
                                          style: const TextStyle(
                                              color: AppColors.taupeGray)),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: Text(
                                              '$setWeight',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (isSetsInReps)
                                            SizedBox(
                                              width: 50,
                                              child: Text(
                                                '$setReps',
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          else
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                formatDurationToHoursMinutesSeconds(
                                                    setDuration),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 20,
                      child: PopupMenuButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side:
                                const BorderSide(color: AppColors.timberwolf)),
                        color: AppColors.white,
                        onSelected: (value) {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                insetPadding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.white,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tr('history_page_edit')),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.pop(context, 'Close'),
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        alignment: Alignment.centerRight,
                                        child: const ClipRect(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            widthFactor: 0.85,
                                            child: Icon(
                                              Icons.close,
                                              color: AppColors.licorice,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                content: Text('data'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              tr('global_edit'),
                              style:
                                  const TextStyle(color: AppColors.taupeGray),
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.frenchGray,
                        ),
                      ),
                    )
                  ],
                );
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          return Text('MULTISET');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildExerciseHeader(Exercise? exercise, TrainingExercise tExercise,
      BuildContext context, bool isSetsInReps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise != null &&
            exercise.imagePath != null &&
            exercise.imagePath!.isNotEmpty)
          Column(
            children: [
              SizedBox(
                width: 130,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(exercise.imagePath!),
                    width: MediaQuery.of(context).size.width - 40,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        if (exercise != null &&
            exercise.imagePath != null &&
            exercise.imagePath!.isNotEmpty)
          const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise != null
                    ? exercise.name
                    : tr('global_exercise_unknown'),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSetsInReps)
                Text('${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps')
              else
                Text('${tExercise.duration} ${tr('active_training_seconds')}'),
              if (tExercise.specialInstructions != null)
                Text('${tExercise.specialInstructions}'),
            ],
          ),
        )
      ],
    );
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
