import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/core/widgets/small_text_field_widget.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/altitude_chart_widget.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/pace_chart_widget.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/run_map_widget.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/save_button_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:collection/collection.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../training_management/domain/entities/multiset.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/history_run_location.dart';

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

    final exerciseIds = sortedItems
        .where((item) => item['type'] == 'exercise')
        .map((item) => (item['data'] as dynamic).id)
        .toList();

    final exerciseIdsFromMultisets = sortedItems
        .where((item) => item['type'] == 'multiset')
        .map((item) => (item['data'] as dynamic).trainingExercises)
        .expand((exercises) => exercises.map((exercise) => exercise.id))
        .toList();

    final allExerciseIds = [...exerciseIds, ...exerciseIdsFromMultisets];

    final deletedTExercisesEntries = state.selectedTrainingEntry!.historyEntries
        .where((entry) => !allExerciseIds.contains(entry.trainingExerciseId))
        .toList();

    Map<int, List<HistoryEntry>> groupedDeleteEntries = groupBy(
      deletedTExercisesEntries,
      (HistoryEntry entry) => entry.multisetId != null
          ? entry.multisetId!
          : entry.trainingExerciseId,
    );

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedItems.length,
          itemBuilder: (context, index) {
            final item = sortedItems[index];
            if (item['type'] == 'exercise') {
              final tExercise = item['data'] as TrainingExercise;

              final matchingExercise = (sl<ExerciseManagementBloc>().state
                      as ExerciseManagementLoaded)
                  .exercises
                  .firstWhereOrNull((e) => e.id == tExercise.exerciseId);

              final entry = state.selectedTrainingEntry!.historyEntries
                  .firstWhere((entry) =>
                      entry.trainingExerciseId == tExercise.id &&
                      entry.setNumber == index);

              final intervalEntries = state
                  .selectedTrainingEntry!.historyEntries
                  .where((entry) =>
                      entry.trainingExerciseId == tExercise.id &&
                      entry.setNumber == index)
                  .toList();

              final locations = state.selectedTrainingEntry!.locations
                  .where((location) =>
                      location.trainingExerciseId == tExercise.id &&
                      location.setNumber == index)
                  .toList();

              return tExercise.trainingExerciseType == TrainingExerciseType.run
                  ? tExercise.sets > 1
                      ? IntervalExercise(
                          trainingExercise: tExercise,
                          historyEntries: intervalEntries,
                          locationsList: locations,
                        )
                      : RunExercise(
                          historyEntry: entry,
                          runLocations: locations,
                          trainingExercise: tExercise,
                        )
                  : ExerciseSetForm(
                      trainingExercise: tExercise,
                      matchingExercise: matchingExercise,
                      historyState: state,
                      training: training,
                      multiset: null,
                      historyEntriesList: null,
                    );
            } else if (item['type'] == 'multiset') {
              final multiset = item['data'] as Multiset;

              List<HistoryEntry> multisetHistoryEntries = state
                  .selectedTrainingEntry!.historyEntries
                  .where((entry) => entry.multisetId == multiset.id)
                  .toList();

              return multiset.trainingExercises.isNotEmpty
                  ? HistoryMultisetWidget(
                      multiset: multiset,
                      historyState: state,
                      training: training,
                      multisetHistoryEntries: multisetHistoryEntries,
                    )
                  : const SizedBox();
            }
            return const SizedBox.shrink();
          },
        ),
        if (deletedTExercisesEntries.isNotEmpty)
          // TODO : afficher les multisets
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedDeleteEntries.length,
              itemBuilder: (context, index) {
                if (groupedDeleteEntries[index + 1]![0].multisetId == null) {
                  List<HistoryEntry> entries = groupedDeleteEntries[index + 1]!;

                  final matchingExercise = (sl<ExerciseManagementBloc>().state
                          as ExerciseManagementLoaded)
                      .exercises
                      .firstWhereOrNull((e) => e.id == entries[0].exerciseId);

                  if (entries[0].trainingExerciseType ==
                      TrainingExerciseType.run) {
                    // TODO
                    return SizedBox();
                  } else {
                    return ExerciseSetForm(
                      trainingExercise: null,
                      matchingExercise: matchingExercise,
                      historyState: state,
                      training: training,
                      multiset: null,
                      historyEntriesList: entries,
                    );
                  }
                } else {
                  return HistoryMultisetWidget(
                    multiset: null,
                    historyState: state,
                    training: training,
                    multisetHistoryEntries: groupedDeleteEntries[index + 1],
                  );
                }
              })
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
        Text('${(entry.setNumber) + 1}'),
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
        Text('${(entry.setNumber) + 1}'),
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

class IntervalExercise extends StatelessWidget {
  final TrainingExercise trainingExercise;
  final List<HistoryEntry> historyEntries;
  final List<RunLocation> locationsList;
  final int? multisetSetIndex;

  const IntervalExercise({
    super.key,
    required this.trainingExercise,
    required this.historyEntries,
    required this.locationsList,
    this.multisetSetIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trainingExercise.sets,
      itemBuilder: (context, index) {
        // Find matching history entry
        final entry = historyEntries.firstWhere((entry) =>
            entry.trainingExerciseId == trainingExercise.id &&
            entry.setNumber == index);
        final locations = locationsList
            .where((location) =>
                location.trainingExerciseId == trainingExercise.id &&
                location.setNumber == index)
            .toList();
        return RunExercise(
          historyEntry: entry,
          runLocations: locations,
          trainingExercise: trainingExercise,
          subtitle:
              '${multisetSetIndex != null ? 'Set ${multisetSetIndex! + 1} - ' : ''} ${tr('history_page_interval')} ${index + 1}',
        );
      },
    );
  }
}

class RunExercise extends StatefulWidget {
  final HistoryEntry historyEntry;
  final List<RunLocation> runLocations;
  final TrainingExercise trainingExercise;
  final String? subtitle;

  const RunExercise({
    super.key,
    required this.historyEntry,
    required this.runLocations,
    required this.trainingExercise,
    this.subtitle,
  });

  @override
  State<RunExercise> createState() => _RunExerciseState();
}

class _RunExerciseState extends State<RunExercise> {
  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    final drop = RunLocation.calculateTotalDrop(widget.runLocations);
    final name = widget.historyEntry.exerciseNameAtTime;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.subtitle != null) Text(widget.subtitle!),
          if (widget.trainingExercise.specialInstructions != null)
            Text('${widget.trainingExercise.specialInstructions}'),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_distance')),
              Text('${widget.historyEntry.distance}m')
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_duration')),
              Text(formatDurationToHoursMinutesSeconds(
                  widget.historyEntry.duration ?? 0))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_pace')),
              Text(formatDurationToHoursMinutesSeconds(
                  widget.historyEntry.pace ?? 0))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(tr('history_page_drop')), Text('${drop}m')],
          ),
          const SizedBox(height: 20),
          ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width - 60) / 3,
            inactiveBgColor: AppColors.whiteSmoke,
            activeBgColor: const [AppColors.licorice],
            activeFgColor: AppColors.white,
            inactiveFgColor: AppColors.licorice,
            cornerRadius: 10,
            radiusStyle: true,
            initialLabelIndex: selectedOption,
            totalSwitches: 3,
            labels: [
              tr('history_page_trace'),
              tr('history_page_pace'),
              tr('history_page_drop')
            ],
            onToggle: (index) {
              setState(() {
                selectedOption = index!;
              });
            },
          ),
          const SizedBox(height: 10),
          if (selectedOption == 0) RunMapView(locations: widget.runLocations),
          if (selectedOption == 1) PaceChart(locations: widget.runLocations),
          if (selectedOption == 2)
            AltitudeChart(locations: widget.runLocations),
        ],
      ),
    );
  }
}

class ExerciseSetForm extends StatefulWidget {
  final Multiset? multiset;
  final TrainingExercise? trainingExercise;
  final Exercise? matchingExercise;
  final TrainingHistoryLoaded historyState;
  final Training? training;
  final List<HistoryEntry>? historyEntriesList;

  const ExerciseSetForm({
    required this.multiset,
    required this.trainingExercise,
    required this.matchingExercise,
    required this.historyState,
    required this.training,
    required this.historyEntriesList,
    super.key,
  });

  @override
  State<ExerciseSetForm> createState() => _ExerciseSetFormState();
}

class _ExerciseSetFormState extends State<ExerciseSetForm> {
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  late List<TextEditingController> durationMinutesControllers;
  late List<TextEditingController> durationSecondsControllers;

  late final bool isSetInReps = widget.trainingExercise?.isSetsInReps ??
      widget.historyEntriesList![0].reps != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final setsCount = widget.multiset?.sets ??
        widget.trainingExercise?.sets ??
        widget.historyEntriesList!.length;
    final isMultiset = widget.multiset != null ||
        widget.historyEntriesList?[0].multisetId != null;

    List<TextEditingController> createControllers(
      String Function(dynamic entry) textExtractor,
    ) {
      return List.generate(
        setsCount,
        (index) {
          final matchingEntry = widget
              .historyState.selectedTrainingEntry!.historyEntries
              .firstWhereOrNull(
            (entry) =>
                entry.trainingExerciseId ==
                    (widget.trainingExercise?.id ??
                        widget.historyEntriesList![0].trainingExerciseId) &&
                (isMultiset
                    ? entry.multisetSetNumber == index
                    : entry.setNumber == index),
          );

          return TextEditingController(text: textExtractor(matchingEntry));
        },
      );
    }

    weightControllers =
        createControllers((entry) => (entry?.weight ?? 0).toString());

    repsControllers =
        createControllers((entry) => (entry?.reps ?? 0).toString());

    durationMinutesControllers = createControllers((entry) =>
        (entry?.duration != null
            ? (entry!.duration! % 3600 ~/ 60).toString()
            : '0'));

    durationSecondsControllers = createControllers((entry) =>
        (entry?.duration != null ? (entry!.duration! % 60).toString() : '0'));
  }

  @override
  void dispose() {
    for (var controller in weightControllers) {
      controller.dispose();
    }
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in durationMinutesControllers) {
      controller.dispose();
    }
    for (var controller in durationSecondsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateHistoryEntry({
    required int setNumber,
    required int? multisetSetNumber,
    int? weight,
    int? reps,
    int? duration,
  }) {
    final historyEntry = widget
        .historyState.selectedTrainingEntry!.historyEntries
        .firstWhereOrNull((entry) =>
            entry.trainingExerciseId ==
                (widget.trainingExercise?.id ??
                    widget.historyEntriesList![0].trainingExerciseId) &&
            entry.multisetSetNumber == multisetSetNumber &&
            entry.setNumber == setNumber);

    DateTime entryDate = DateTime.now();

    if (widget.historyState.selectedTrainingEntry!.historyEntries.isNotEmpty) {
      entryDate = widget.historyState.selectedTrainingEntry!.historyEntries
          .map((e) => e.date)
          .reduce((value, element) => value.isAfter(element) ? value : element);
    }
    int? cals = historyEntry?.calories;
    cals = isSetInReps
        ? getCalories(
            intensity: widget.trainingExercise?.intensity ??
                widget.historyEntriesList![0].intensity,
            reps: reps ?? historyEntry?.reps)
        : getCalories(
            intensity: widget.trainingExercise?.intensity ??
                widget.historyEntriesList![0].intensity,
            duration: duration ?? historyEntry?.duration);

    context.read<TrainingHistoryBloc>().add(
          CreateOrUpdateHistoryEntry(
            historyEntry: HistoryEntry(
              id: historyEntry?.id,
              trainingId: historyEntry?.trainingId ??
                  widget.trainingExercise?.trainingId ??
                  widget.historyEntriesList![0].trainingId,
              trainingType: historyEntry?.trainingType ??
                  widget.training?.type ??
                  widget.historyEntriesList![0].trainingType,
              trainingExerciseId: historyEntry?.trainingExerciseId ??
                  widget.trainingExercise?.id ??
                  widget.historyEntriesList![0].trainingExerciseId,
              trainingExerciseType: historyEntry?.trainingExerciseType ??
                  widget.trainingExercise?.trainingExerciseType ??
                  widget.historyEntriesList![0].trainingExerciseType,
              date: historyEntry?.date ?? entryDate,
              trainingNameAtTime: historyEntry?.trainingNameAtTime ??
                  widget.training?.name ??
                  widget.historyEntriesList![0].trainingNameAtTime,
              exerciseNameAtTime: historyEntry?.exerciseNameAtTime ??
                  findExerciseName(widget.trainingExercise) ??
                  widget.historyEntriesList![0].exerciseNameAtTime,
              intensity: historyEntry?.intensity ??
                  widget.trainingExercise?.intensity ??
                  widget.historyEntriesList![0].intensity,
              weight: weight ?? historyEntry?.weight,
              reps: reps ?? historyEntry?.reps,
              duration: duration ?? historyEntry?.duration,
              setNumber: historyEntry?.setNumber ?? setNumber,
              multisetSetNumber:
                  historyEntry?.multisetSetNumber ?? multisetSetNumber,
              distance: null,
              pace: null,
              calories: cals,
              exerciseId: historyEntry?.exerciseId ??
                  widget.trainingExercise?.exerciseId ??
                  widget.historyEntriesList?[0].exerciseId,
              multisetId: historyEntry?.multisetId ??
                  widget.trainingExercise?.multisetId ??
                  widget.historyEntriesList?[0].multisetId,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          _buildExerciseHeader(
            widget.matchingExercise,
            widget.trainingExercise,
            context,
            isSetInReps,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          _buildHeaderRow(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.multiset?.sets ??
                widget.trainingExercise?.sets ??
                widget.historyEntriesList!.length,
            itemBuilder: (context, index) {
              return _buildSetRow(index, widget.multiset != null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(Exercise? exercise, TrainingExercise? tExercise,
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
              if (isSetsInReps && tExercise != null)
                Text('${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps')
              else if (tExercise != null)
                Text('${tExercise.duration} ${tr('active_training_seconds')}'),
              if (tExercise != null && tExercise.specialInstructions != null)
                Text('${tExercise.specialInstructions}'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSetRow(int index, bool isMultiset) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${index + 1}',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          Row(
            children: [
              SizedBox(
                width: 50,
                child:
                    SmallTextFieldWidget(controller: weightControllers[index]),
              ),
              const SizedBox(width: 10),
              if (isSetInReps)
                SizedBox(
                  width: 50,
                  child:
                      SmallTextFieldWidget(controller: repsControllers[index]),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: SmallTextFieldWidget(
                          controller: durationMinutesControllers[index]),
                    ),
                    const SizedBox(
                      width: 10,
                      child: Text(
                        ':',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: SmallTextFieldWidget(
                          controller: durationSecondsControllers[index]),
                    ),
                  ],
                ),
              const SizedBox(width: 10),
              SaveButton(onTapCallback: () {
                final duration = ((int.tryParse(
                                durationMinutesControllers[index].text) ??
                            0) *
                        60) +
                    ((int.tryParse(durationSecondsControllers[index].text) ??
                        0));
                _updateHistoryEntry(
                  setNumber: isMultiset ? 1 : index,
                  multisetSetNumber: isMultiset ? index : null,
                  weight: int.tryParse(weightControllers[index].text),
                  duration: duration,
                  reps: int.tryParse(repsControllers[index].text),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Sets', style: TextStyle(color: AppColors.taupeGray)),
        Row(
          children: [
            const SizedBox(
              width: 50,
              child: Center(
                child: Text(
                  'Kg',
                  style: TextStyle(color: AppColors.taupeGray),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (isSetInReps)
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
                width: 110,
                child: Center(
                  child: Text(
                    'Duration',
                    style: TextStyle(color: AppColors.taupeGray),
                  ),
                ),
              ),
            const SizedBox(width: 46)
          ],
        ),
      ],
    );
  }
}

class HistoryMultisetWidget extends StatelessWidget {
  final Multiset? multiset;
  final TrainingHistoryLoaded historyState;
  final Training? training;
  final List<HistoryEntry>? multisetHistoryEntries;

  const HistoryMultisetWidget({
    super.key,
    required this.multiset,
    required this.historyState,
    required this.training,
    required this.multisetHistoryEntries,
  });

  @override
  Widget build(BuildContext context) {
    Map<int, List<HistoryEntry>>? groupedBySetEntries;
    Map<int, List<HistoryEntry>>? groupedByTExerciseEntries;
    if (multisetHistoryEntries != null) {
      groupedBySetEntries = groupBy(
        multisetHistoryEntries!.sorted(
            (a, b) => a.multisetSetNumber!.compareTo(b.multisetSetNumber!)),
        (HistoryEntry entry) => entry.multisetSetNumber!,
      );
      groupedByTExerciseEntries = groupBy(
        multisetHistoryEntries!.sorted(
            (a, b) => a.trainingExerciseId.compareTo(b.trainingExerciseId)),
        (HistoryEntry entry) => entry.trainingExerciseId,
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('global_multiset'),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text('${multiset?.sets ?? groupedBySetEntries!.length} sets'),
          if ((multiset != null && multiset!.trainingExercises.isNotEmpty) ||
              (groupedByTExerciseEntries != null &&
                  groupedByTExerciseEntries.isNotEmpty))
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: multiset?.trainingExercises.length ??
                  groupedByTExerciseEntries!.length,
              itemBuilder: (context, multisetExerciseindex) {
                final tExercise =
                    multiset?.trainingExercises[multisetExerciseindex];

                final matchingExercise = (sl<ExerciseManagementBloc>().state
                        as ExerciseManagementLoaded)
                    .exercises
                    .firstWhereOrNull((e) =>
                        e.id ==
                        (tExercise?.exerciseId ??
                            groupedByTExerciseEntries![multisetExerciseindex]![
                                    0]
                                .exerciseId));

                final entries =
                    groupedByTExerciseEntries![multisetExerciseindex + 1];

                if ((tExercise?.trainingExerciseType ??
                        entries![0].trainingExerciseType) !=
                    TrainingExerciseType.run) {
                  return ExerciseSetForm(
                    trainingExercise: tExercise,
                    matchingExercise: matchingExercise,
                    historyState: historyState,
                    training: training,
                    multiset: multiset,
                    historyEntriesList: entries,
                  );
                } else {
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: multiset?.sets ?? groupedBySetEntries!.length,
                      itemBuilder: (context, multisetSetindex) {
                        final entry = historyState
                            .selectedTrainingEntry!.historyEntries
                            .firstWhere((entry) =>
                                entry.trainingExerciseId ==
                                    (tExercise?.id ??
                                        groupedByTExerciseEntries![
                                                multisetExerciseindex]![0]
                                            .trainingExerciseId) &&
                                entry.multisetSetNumber == multisetSetindex);

                        final locations = historyState
                            .selectedTrainingEntry!.locations
                            .where((location) =>
                                location.trainingExerciseId ==
                                    (tExercise?.id ??
                                        groupedByTExerciseEntries![
                                                multisetExerciseindex]![0]
                                            .trainingExerciseId) &&
                                location.multisetSetNumber == multisetSetindex)
                            .toList();

                        final intervalEntries = historyState
                            .selectedTrainingEntry!.historyEntries
                            .where((entry) =>
                                entry.trainingExerciseId ==
                                    (tExercise?.id ??
                                        groupedByTExerciseEntries![
                                                multisetExerciseindex]![0]
                                            .trainingExerciseId) &&
                                entry.multisetSetNumber == multisetSetindex)
                            .toList();

                        // return tExercise.sets > 1
                        //     ? IntervalExercise(
                        //         trainingExercise: tExercise,
                        //         multisetSetIndex: multisetSetindex,
                        //         historyEntries: intervalEntries,
                        //         locationsList: locations,
                        //       )
                        //     : RunExercise(
                        //         historyEntry: entry,
                        //         runLocations: locations,
                        //         trainingExercise: tExercise,
                        //         subtitle: '(set ${multisetSetindex + 1})',
                        //       );
                      });
                }
              },
            )
        ],
      ),
    );
  }
}
